# Local File Organizer - Environment Verification Script
# This script checks if all requirements are properly installed

$ErrorActionPreference = "Continue"

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

function Test-CommandExists {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Test-PythonPackage {
    param($PackageName)
    try {
        $result = python -c "import $PackageName; print('OK')" 2>&1
        return $result -eq "OK"
    }
    catch {
        return $false
    }
}

Write-Header "Environment Verification for Local File Organizer"

$allChecks = @()

# Check Python
Write-ColorText "Checking Python..." $Yellow
if (Test-CommandExists "python") {
    $pythonVersion = python --version 2>&1
    Write-ColorText "✓ Python found: $pythonVersion" $Green
    $allChecks += @{Name="Python"; Status="OK"; Details=$pythonVersion}
    
    # Check Python version compatibility
    $versionMatch = $pythonVersion -match "Python (\d+)\.(\d+)"
    if ($versionMatch) {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 8)) {
            Write-ColorText "⚠ Warning: Python 3.8+ recommended for best compatibility" $Yellow
        }
    }
} else {
    Write-ColorText "✗ Python not found" $Red
    $allChecks += @{Name="Python"; Status="MISSING"; Details="Not found in PATH"}
}

# Check Conda
Write-ColorText "Checking Conda..." $Yellow
$condaFound = $false
$condaPaths = @("conda", "mamba", "$env:USERPROFILE\miniconda3\Scripts\conda.exe", "$env:USERPROFILE\anaconda3\Scripts\conda.exe")

foreach ($path in $condaPaths) {
    if (Test-CommandExists $path) {
        $condaVersion = & $path --version 2>&1
        Write-ColorText "✓ Conda found: $condaVersion" $Green
        $allChecks += @{Name="Conda"; Status="OK"; Details=$condaVersion}
        $condaFound = $true
        break
    }
}

if (-not $condaFound) {
    Write-ColorText "✗ Conda not found" $Red
    $allChecks += @{Name="Conda"; Status="MISSING"; Details="Not found in PATH"}
}

# Check Tesseract OCR
Write-ColorText "Checking Tesseract OCR..." $Yellow
if (Test-CommandExists "tesseract") {
    $tesseractVersion = tesseract --version 2>&1 | Select-Object -First 1
    Write-ColorText "✓ Tesseract found: $tesseractVersion" $Green
    $allChecks += @{Name="Tesseract"; Status="OK"; Details=$tesseractVersion}
} else {
    Write-ColorText "✗ Tesseract OCR not found" $Red
    Write-ColorText "  Download from: https://github.com/UB-Mannheim/tesseract/wiki" $Yellow
    $allChecks += @{Name="Tesseract"; Status="MISSING"; Details="Not found in PATH"}
}

# Check if conda environment exists
Write-ColorText "Checking conda environment 'local_file_organizer'..." $Yellow
if ($condaFound) {
    try {
        $envList = conda env list 2>&1
        if ($envList -match "local_file_organizer") {
            Write-ColorText "✓ Conda environment 'local_file_organizer' found" $Green
            $allChecks += @{Name="Conda Environment"; Status="OK"; Details="local_file_organizer exists"}
            
            # Test activation and packages within environment
            Write-ColorText "Testing conda environment activation..." $Yellow
            $activateScript = "$env:USERPROFILE\miniconda3\Scripts\activate.bat"
            if (-not (Test-Path $activateScript)) {
                $activateScript = "$env:USERPROFILE\anaconda3\Scripts\activate.bat"
            }
            
            if (Test-Path $activateScript) {
                # Check Python packages in conda environment
                Write-Header "Checking Python Packages in Conda Environment"
                
                $packages = @(
                    @{Name="nexa"; ImportName="nexa"},
                    @{Name="pytesseract"; ImportName="pytesseract"},
                    @{Name="PyMuPDF"; ImportName="fitz"},
                    @{Name="python-docx"; ImportName="docx"},
                    @{Name="pandas"; ImportName="pandas"},
                    @{Name="openpyxl"; ImportName="openpyxl"},
                    @{Name="nltk"; ImportName="nltk"},
                    @{Name="rich"; ImportName="rich"},
                    @{Name="python-pptx"; ImportName="pptx"},
                    @{Name="Pillow"; ImportName="PIL"}
                )
                
                foreach ($pkg in $packages) {
                    Write-ColorText "Checking $($pkg.Name)..." $Yellow
                    
                    $checkCmd = @"
call "$activateScript" local_file_organizer && python -c "import $($pkg.ImportName); print('OK')"
"@
                    
                    $result = cmd /c $checkCmd 2>&1
                    if ($result -match "OK") {
                        Write-ColorText "✓ $($pkg.Name) installed" $Green
                        $allChecks += @{Name=$pkg.Name; Status="OK"; Details="Installed in conda env"}
                    } else {
                        Write-ColorText "✗ $($pkg.Name) not found or has issues" $Red
                        $allChecks += @{Name=$pkg.Name; Status="MISSING"; Details="Not installed or import error"}
                    }
                }
                
                # Check NLTK data
                Write-ColorText "Checking NLTK data..." $Yellow
                $nltkCmd = @"
call "$activateScript" local_file_organizer && python -c "
import nltk
try:
    nltk.data.find('tokenizers/punkt')
    nltk.data.find('corpora/stopwords')
    nltk.data.find('corpora/wordnet')
    print('NLTK_DATA_OK')
except:
    print('NLTK_DATA_MISSING')
"
"@
                
                $nltkResult = cmd /c $nltkCmd 2>&1
                if ($nltkResult -match "NLTK_DATA_OK") {
                    Write-ColorText "✓ NLTK data available" $Green
                    $allChecks += @{Name="NLTK Data"; Status="OK"; Details="Required datasets available"}
                } else {
                    Write-ColorText "✗ NLTK data missing" $Red
                    $allChecks += @{Name="NLTK Data"; Status="MISSING"; Details="Required datasets not downloaded"}
                }
                
            } else {
                Write-ColorText "✗ Cannot find conda activation script" $Red
                $allChecks += @{Name="Conda Activation"; Status="ERROR"; Details="Activation script not found"}
            }
            
        } else {
            Write-ColorText "✗ Conda environment 'local_file_organizer' not found" $Red
            $allChecks += @{Name="Conda Environment"; Status="MISSING"; Details="Environment not created"}
        }
    }
    catch {
        Write-ColorText "✗ Error checking conda environments" $Red
        $allChecks += @{Name="Conda Environment"; Status="ERROR"; Details="Could not list environments"}
    }
} else {
    Write-ColorText "⚠ Cannot check conda environment (Conda not available)" $Yellow
}

# Check project files
Write-Header "Checking Project Files"

$projectFiles = @("main.py", "requirements.txt", "diagnostic.py", "diagnostic_simple.py")
foreach ($file in $projectFiles) {
    if (Test-Path $file) {
        Write-ColorText "✓ $file found" $Green
        $allChecks += @{Name="File: $file"; Status="OK"; Details="Present"}
    } else {
        Write-ColorText "✗ $file not found" $Red
        $allChecks += @{Name="File: $file"; Status="MISSING"; Details="File not found"}
    }
}

# Summary
Write-Header "Verification Summary"

$okCount = ($allChecks | Where-Object {$_.Status -eq "OK"}).Count
$missingCount = ($allChecks | Where-Object {$_.Status -eq "MISSING"}).Count
$errorCount = ($allChecks | Where-Object {$_.Status -eq "ERROR"}).Count
$totalCount = $allChecks.Count

Write-ColorText "Total items checked: $totalCount" $Cyan
Write-ColorText "✓ OK: $okCount" $Green
Write-ColorText "✗ Missing: $missingCount" $Red
Write-ColorText "⚠ Errors: $errorCount" $Yellow

if ($missingCount -eq 0 -and $errorCount -eq 0) {
    Write-Host ""
    Write-ColorText "🎉 All checks passed! Your environment is ready." $Green
    Write-ColorText "You can run the application with: python main.py" $Cyan
} elseif ($missingCount -gt 0) {
    Write-Host ""
    Write-ColorText "⚠ Some components are missing. Run setup.ps1 to install them." $Yellow
    Write-ColorText "Missing items:" $Red
    $allChecks | Where-Object {$_.Status -eq "MISSING"} | ForEach-Object {
        Write-ColorText "  - $($_.Name): $($_.Details)" $Red
    }
} else {
    Write-Host ""
    Write-ColorText "⚠ Some components have errors. Check the details above." $Yellow
}

# Detailed report
Write-Header "Detailed Report"
$allChecks | ForEach-Object {
    $statusColor = switch($_.Status) {
        "OK" { $Green }
        "MISSING" { $Red }
        "ERROR" { $Yellow }
        default { "White" }
    }
    Write-Host "$($_.Name): " -NoNewline
    Write-ColorText "$($_.Status)" $statusColor
    if ($_.Details) {
        Write-ColorText "  Details: $($_.Details)" "Gray"
    }
}

Write-Host ""
Write-ColorText "Verification completed." $Cyan