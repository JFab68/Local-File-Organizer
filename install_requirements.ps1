# Requirements Installation Script for Local File Organizer
# This script handles the installation of all Python requirements

param(
    [string]$CondaEnv = "local_file_organizer",
    [switch]$Force,
    [switch]$Individual,
    [string]$RequirementsFile = "requirements.txt"
)

$ErrorActionPreference = "Stop"

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

function Write-ColorText {
    param($Text, $Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Write-Header {
    param($Text)
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
}

function Test-PackageInstalled {
    param($PackageName, $ImportName = $PackageName)
    
    $testCmd = @"
call "$activateScript" $CondaEnv && python -c "
try:
    import $ImportName
    print('INSTALLED')
except ImportError:
    print('NOT_INSTALLED')
"
"@
    
    $result = cmd /c $testCmd 2>$null
    return $result -match "INSTALLED"
}

Write-Header "Requirements Installation for Local File Organizer"

# Find conda activation script
$activateScript = ""
$condaPaths = @(
    "$env:USERPROFILE\miniconda3\Scripts\activate.bat",
    "$env:USERPROFILE\anaconda3\Scripts\activate.bat",
    "$env:PROGRAMDATA\Miniconda3\Scripts\activate.bat",
    "$env:PROGRAMDATA\Anaconda3\Scripts\activate.bat"
)

foreach ($path in $condaPaths) {
    if (Test-Path $path) {
        $activateScript = $path
        break
    }
}

if ($activateScript -eq "") {
    Write-ColorText "✗ Could not find conda activation script" $Red
    exit 1
}

Write-ColorText "Using conda activation script: $activateScript" $Yellow

# Check if environment exists
Write-ColorText "Checking conda environment '$CondaEnv'..." $Yellow
$envExists = conda env list 2>&1 | Select-String $CondaEnv
if (-not $envExists) {
    Write-ColorText "✗ Conda environment '$CondaEnv' not found" $Red
    Write-ColorText "Create it first with: conda create -n $CondaEnv python=3.12 -y" $Yellow
    exit 1
}

Write-ColorText "✓ Environment found: $CondaEnv" $Green

# Check if requirements file exists
if (-not (Test-Path $RequirementsFile)) {
    Write-ColorText "✗ Requirements file not found: $RequirementsFile" $Red
    exit 1
}

Write-ColorText "✓ Requirements file found: $RequirementsFile" $Green

# Read requirements file
$requirements = Get-Content $RequirementsFile | Where-Object { $_ -match '\S' -and -not $_.StartsWith('#') }
Write-ColorText "Found $($requirements.Count) packages in requirements file" $Cyan

# Display requirements
Write-ColorText "Packages to install:" $Yellow
$requirements | ForEach-Object { Write-ColorText "  - $_" "Gray" }

# Package mapping for import names
$packageMapping = @{
    "pytesseract" = "pytesseract"
    "PyMuPDF" = "fitz"
    "python-docx" = "docx"
    "pandas" = "pandas"
    "openpyxl" = "openpyxl"
    "xlrd" = "xlrd"
    "nltk" = "nltk"
    "rich" = "rich"
    "python-pptx" = "pptx"
    "cmake" = $null  # cmake is a build tool, not a Python package
    "Pillow" = "PIL"
}

# Check currently installed packages (if not Force)
if (-not $Force) {
    Write-Header "Checking Currently Installed Packages"
    
    $alreadyInstalled = @()
    $needInstallation = @()
    
    foreach ($pkg in $requirements) {
        $cleanPkg = $pkg.Trim()
        $importName = $packageMapping[$cleanPkg]
        
        if ($importName -eq $null -and $cleanPkg -eq "cmake") {
            Write-ColorText "$cleanPkg (build tool) - checking..." $Yellow
            # For cmake, just check if it's installed via pip
            $cmakeCheck = cmd /c "call `"$activateScript`" $CondaEnv && pip show cmake" 2>$null
            if ($cmakeCheck -match "Name: cmake") {
                Write-ColorText "✓ $cleanPkg already installed" $Green
                $alreadyInstalled += $cleanPkg
            }
            else {
                Write-ColorText "⚬ $cleanPkg needs installation" $Yellow
                $needInstallation += $cleanPkg
            }
        }
        elseif ($importName) {
            Write-ColorText "Checking $cleanPkg..." $Yellow
            if (Test-PackageInstalled $cleanPkg $importName) {
                Write-ColorText "✓ $cleanPkg already installed" $Green
                $alreadyInstalled += $cleanPkg
            }
            else {
                Write-ColorText "⚬ $cleanPkg needs installation" $Yellow
                $needInstallation += $cleanPkg
            }
        }
        else {
            Write-ColorText "⚬ $cleanPkg needs installation (unknown import)" $Yellow
            $needInstallation += $cleanPkg
        }
    }
    
    Write-Host ""
    Write-ColorText "Already installed: $($alreadyInstalled.Count)" $Green
    Write-ColorText "Need installation: $($needInstallation.Count)" $Yellow
    
    if ($needInstallation.Count -eq 0) {
        Write-ColorText "✓ All requirements already satisfied!" $Green
        exit 0
    }
}

# Installation methods
if ($Individual -or $Force) {
    Write-Header "Installing Packages Individually"
    
    $packagesToInstall = if ($Force) { $requirements } else { $needInstallation }
    $successCount = 0
    $failureCount = 0
    $failures = @()
    
    foreach ($pkg in $packagesToInstall) {
        $cleanPkg = $pkg.Trim()
        Write-ColorText "Installing $cleanPkg..." $Yellow
        
        $installCmd = @"
call "$activateScript" $CondaEnv && pip install "$cleanPkg"
"@
        
        try {
            cmd /c $installCmd
            if ($LASTEXITCODE -eq 0) {
                Write-ColorText "✓ $cleanPkg installed successfully" $Green
                $successCount++
            }
            else {
                Write-ColorText "✗ Failed to install $cleanPkg" $Red
                $failureCount++
                $failures += $cleanPkg
            }
        }
        catch {
            Write-ColorText "✗ Error installing $cleanPkg : $($_.Exception.Message)" $Red
            $failureCount++
            $failures += $cleanPkg
        }
    }
    
    Write-Host ""
    Write-ColorText "Installation Summary:" $Cyan
    Write-ColorText "✓ Successfully installed: $successCount" $Green
    Write-ColorText "✗ Failed installations: $failureCount" $Red
    
    if ($failures.Count -gt 0) {
        Write-ColorText "Failed packages:" $Red
        $failures | ForEach-Object { Write-ColorText "  - $_" $Red }
    }
}
else {
    Write-Header "Installing from Requirements File"
    
    Write-ColorText "Installing all requirements..." $Yellow
    $batchInstallCmd = @"
call "$activateScript" $CondaEnv && pip install -r "$RequirementsFile"
"@
    
    try {
        cmd /c $batchInstallCmd
        if ($LASTEXITCODE -eq 0) {
            Write-ColorText "✓ All requirements installed successfully" $Green
        }
        else {
            Write-ColorText "⚠ Batch installation had issues. Trying individual installation..." $Yellow
            
            # Retry with individual installation
            Write-Header "Retrying with Individual Installation"
            
            $successCount = 0
            $failureCount = 0
            $failures = @()
            
            foreach ($pkg in $requirements) {
                $cleanPkg = $pkg.Trim()
                Write-ColorText "Installing $cleanPkg..." $Yellow
                
                $installCmd = @"
call "$activateScript" $CondaEnv && pip install "$cleanPkg"
"@
                
                try {
                    cmd /c $installCmd
                    if ($LASTEXITCODE -eq 0) {
                        Write-ColorText "✓ $cleanPkg installed" $Green
                        $successCount++
                    }
                    else {
                        Write-ColorText "✗ Failed: $cleanPkg" $Red
                        $failureCount++
                        $failures += $cleanPkg
                    }
                }
                catch {
                    Write-ColorText "✗ Error: $cleanPkg" $Red
                    $failureCount++
                    $failures += $cleanPkg
                }
            }
            
            Write-Host ""
            Write-ColorText "Individual Installation Summary:" $Cyan
            Write-ColorText "✓ Successfully installed: $successCount" $Green
            Write-ColorText "✗ Failed installations: $failureCount" $Red
        }
    }
    catch {
        Write-ColorText "✗ Batch installation failed: $($_.Exception.Message)" $Red
        exit 1
    }
}

# Install NLTK data
Write-Header "Installing NLTK Data"

Write-ColorText "Downloading required NLTK datasets..." $Yellow
$nltkCmd = @"
call "$activateScript" $CondaEnv && python -c "
import nltk
import ssl

# Handle SSL issues
try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    pass
else:
    ssl._create_default_https_context = _create_unverified_https_context

# Download required data
datasets = ['stopwords', 'punkt', 'wordnet']
for dataset in datasets:
    try:
        nltk.download(dataset, quiet=True)
        print(f'✓ {dataset} downloaded')
    except Exception as e:
        print(f'⚠ {dataset} download failed: {e}')

print('NLTK data installation completed')
"
"@

cmd /c $nltkCmd

# Verification
Write-Header "Verifying Installation"

Write-ColorText "Testing package imports..." $Yellow
$verifyCmd = @"
call "$activateScript" $CondaEnv && python -c "
import sys
packages_to_test = [
    ('pytesseract', 'pytesseract'),
    ('PyMuPDF', 'fitz'),
    ('python-docx', 'docx'), 
    ('pandas', 'pandas'),
    ('openpyxl', 'openpyxl'),
    ('nltk', 'nltk'),
    ('rich', 'rich'),
    ('python-pptx', 'pptx')
]

success_count = 0
total_count = len(packages_to_test)

for package_name, import_name in packages_to_test:
    try:
        __import__(import_name)
        print(f'✓ {package_name} import successful')
        success_count += 1
    except ImportError as e:
        print(f'✗ {package_name} import failed: {e}')

print(f'\\nVerification: {success_count}/{total_count} packages working')
if success_count == total_count:
    print('✓ All packages verified successfully!')
    sys.exit(0)
else:
    print('⚠ Some packages have import issues')
    sys.exit(1)
"
"@

cmd /c $verifyCmd

if ($LASTEXITCODE -eq 0) {
    Write-ColorText "✓ All packages verified successfully!" $Green
}
else {
    Write-ColorText "⚠ Some packages have verification issues" $Yellow
}

Write-Header "Installation Complete"

Write-ColorText "Requirements installation finished!" $Green
Write-Host ""
Write-ColorText "To test your installation:" $Cyan
Write-ColorText "1. conda activate $CondaEnv" $Yellow
Write-ColorText "2. python diagnostic.py" $Yellow
Write-Host ""
Write-ColorText "To run the application:" $Cyan  
Write-ColorText "1. conda activate $CondaEnv" $Yellow
Write-ColorText "2. python main.py" $Yellow

# Show any remaining issues
if ($failures -and $failures.Count -gt 0) {
    Write-Host ""
    Write-ColorText "Note: The following packages failed to install:" $Yellow
    $failures | ForEach-Object { Write-ColorText "  - $_" $Red }
    Write-ColorText "You may need to install these manually or check for system dependencies." $Yellow
}