# Local File Organizer - Windows PowerShell Setup Script
# This script automates the complete setup process for the Local File Organizer

param(
    [switch]$Force,
    [switch]$SkipEnvCheck,
    [string]$CondaPath = ""
)

# Set execution policy and error handling
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
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

Write-Header "Local File Organizer - Windows Setup"
Write-ColorText "Starting automated setup process..." $Cyan

# Step 1: Check prerequisites
Write-Header "Step 1: Checking Prerequisites"

if (-not $SkipEnvCheck) {
    Write-ColorText "Checking Python installation..." $Yellow
    if (Test-CommandExists "python") {
        $pythonVersion = python --version 2>&1
        Write-ColorText "OK Found: $pythonVersion" $Green
        
        # Check if Python version is compatible (3.8+)
        $versionMatch = $pythonVersion -match "Python (\d+)\.(\d+)"
        if ($versionMatch) {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 8)) {
                Write-ColorText "WARNING: Python 3.8+ recommended. Found: $pythonVersion" $Yellow
            }
        }
    }
    else {
        Write-ColorText "ERROR: Python not found. Please install Python 3.8+ first." $Red
        exit 1
    }

    Write-ColorText "Checking Conda installation..." $Yellow
    $condaFound = $false
    $condaCommand = ""
    
    # Check for conda in various locations
    $condaPaths = @("conda", "mamba", "$env:USERPROFILE\miniconda3\Scripts\conda.exe", "$env:USERPROFILE\anaconda3\Scripts\conda.exe")
    
    if ($CondaPath -ne "") {
        $condaPaths = @($CondaPath) + $condaPaths
    }
    
    foreach ($path in $condaPaths) {
        if (Test-CommandExists $path) {
            $condaFound = $true
            $condaCommand = $path
            break
        }
    }
    
    if ($condaFound) {
        $condaVersion = & $condaCommand --version 2>&1
        Write-ColorText "OK Found: $condaVersion" $Green
    }
    else {
        Write-ColorText "ERROR: Conda not found. Installing Miniconda..." $Yellow
        
        # Download and install Miniconda
        $minicondaUrl = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
        $minicondaInstaller = "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe"
        
        Write-ColorText "Downloading Miniconda..." $Yellow
        Invoke-WebRequest -Uri $minicondaUrl -OutFile $minicondaInstaller
        
        Write-ColorText "Installing Miniconda (this may take a few minutes)..." $Yellow
        Start-Process -FilePath $minicondaInstaller -ArgumentList "/S", "/D=$env:USERPROFILE\miniconda3" -Wait
        
        # Add conda to PATH for current session
        $env:PATH += ";$env:USERPROFILE\miniconda3\Scripts"
        $condaCommand = "$env:USERPROFILE\miniconda3\Scripts\conda.exe"
        
        if (Test-Path $condaCommand) {
            Write-ColorText "OK Miniconda installed successfully" $Green
        }
        else {
            Write-ColorText "ERROR: Failed to install Miniconda" $Red
            exit 1
        }
    }

    Write-ColorText "Checking Tesseract OCR..." $Yellow
    if (Test-CommandExists "tesseract") {
        $tesseractVersion = tesseract --version 2>&1 | Select-Object -First 1
        Write-ColorText "OK Found: $tesseractVersion" $Green
    }
    else {
        Write-ColorText "WARNING: Tesseract OCR not found in PATH. Please ensure it's installed and added to PATH." $Yellow
        Write-ColorText "  Download from: https://github.com/UB-Mannheim/tesseract/wiki" $Yellow
    }
}

# Step 2: Create and activate conda environment
Write-Header "Step 2: Setting up Conda Environment"

Write-ColorText "Creating conda environment 'local_file_organizer'..." $Yellow
try {
    # Remove existing environment if Force is specified
    if ($Force) {
        Write-ColorText "Removing existing environment..." $Yellow
        & $condaCommand env remove -n local_file_organizer -y 2>$null
    }
    
    # Create new environment with Python 3.12
    & $condaCommand create -n local_file_organizer python=3.12 -y
    Write-ColorText "OK Environment created successfully" $Green
}
catch {
    if ($_.Exception.Message -like "*already exists*") {
        Write-ColorText "Environment already exists. Use -Force to recreate." $Yellow
    }
    else {
        Write-ColorText "ERROR: Failed to create environment: $($_.Exception.Message)" $Red
        exit 1
    }
}

# Step 3: Install Nexa SDK
Write-Header "Step 3: Installing Nexa SDK"

Write-ColorText "Activating conda environment..." $Yellow
$activateScript = "$env:USERPROFILE\miniconda3\Scripts\activate.bat"
if (-not (Test-Path $activateScript)) {
    $activateScript = "$env:USERPROFILE\anaconda3\Scripts\activate.bat"
}

Write-ColorText "Installing Nexa SDK (CPU version)..." $Yellow
$nexaInstallCmd = "call `"$activateScript`" local_file_organizer `&`& pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/cpu --extra-index-url https://pypi.org/simple --no-cache-dir"

cmd /c $nexaInstallCmd
if ($LASTEXITCODE -eq 0) {
    Write-ColorText "OK Nexa SDK installed successfully" $Green
}
else {
    Write-ColorText "ERROR: Failed to install Nexa SDK" $Red
    exit 1
}

# Step 4: Install Python requirements
Write-Header "Step 4: Installing Python Requirements"

Write-ColorText "Installing project requirements..." $Yellow
$requirementsCmd = "call `"$activateScript`" local_file_organizer `&`& pip install -r requirements.txt"

cmd /c $requirementsCmd
if ($LASTEXITCODE -eq 0) {
    Write-ColorText "OK Requirements installed successfully" $Green
}
else {
    Write-ColorText "WARNING: Some requirements may have failed. Installing individually..." $Yellow
    
    # Install packages individually
    $packages = @("pytesseract", "PyMuPDF", "python-docx", "pandas", "openpyxl", "xlrd", "nltk", "rich", "python-pptx", "cmake")
    
    foreach ($package in $packages) {
        Write-ColorText "Installing $package..." $Yellow
        $individualCmd = "call `"$activateScript`" local_file_organizer `&`& pip install $package"
        cmd /c $individualCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorText "OK $package installed" $Green
        }
        else {
            Write-ColorText "ERROR: Failed to install $package" $Red
        }
    }
}

# Step 5: Download NLTK data
Write-Header "Step 5: Downloading NLTK Data"

Write-ColorText "Downloading required NLTK data..." $Yellow
$nltkCmd = "call `"$activateScript`" local_file_organizer `&`& python -c `"import nltk; nltk.download('stopwords', quiet=True); nltk.download('punkt', quiet=True); nltk.download('wordnet', quiet=True); print('NLTK data downloaded successfully')`""

cmd /c $nltkCmd
if ($LASTEXITCODE -eq 0) {
    Write-ColorText "OK NLTK data downloaded successfully" $Green
}
else {
    Write-ColorText "WARNING: NLTK data download may have issues" $Yellow
}

# Step 6: Test installation
Write-Header "Step 6: Testing Installation"

Write-ColorText "Running diagnostic test..." $Yellow
$diagnosticCmd = "call `"$activateScript`" local_file_organizer `&`& python diagnostic_simple.py"

cmd /c $diagnosticCmd
if ($LASTEXITCODE -eq 0) {
    Write-ColorText "OK Diagnostic test passed" $Green
}
else {
    Write-ColorText "WARNING: Diagnostic test had issues - check output above" $Yellow
}

# Final instructions
Write-Header "Setup Complete!"

Write-ColorText "Installation completed successfully!" $Green
Write-Host ""
Write-ColorText "To use the Local File Organizer:" $Cyan
Write-ColorText "1. Open a new PowerShell/Command Prompt" $Yellow
Write-ColorText "2. Activate the environment:" $Yellow
Write-ColorText "   conda activate local_file_organizer" $Green
Write-ColorText "3. Run the application:" $Yellow
Write-ColorText "   python main.py" $Green
Write-Host ""
Write-ColorText "For testing with sample data:" $Yellow
Write-ColorText "   python main.py" $Green
Write-Host ""
Write-ColorText "Batch files have been created for easy access:" $Cyan
Write-ColorText "- run_organizer.bat - Quick start the application" $Yellow
Write-ColorText "- test_organizer.bat - Run diagnostic tests" $Yellow

# Create batch files for easy access
Write-ColorText "Creating convenience batch files..." $Yellow

# Create run batch file
$runBatch = @"
@echo off
echo Local File Organizer - Starting Application
call "$activateScript" local_file_organizer
python main.py
pause
"@
Set-Content -Path "run_organizer.bat" -Value $runBatch

# Create test batch file
$testBatch = @"
@echo off
echo Local File Organizer - Running Tests
call "$activateScript" local_file_organizer
python diagnostic.py
pause
"@
Set-Content -Path "test_organizer.bat" -Value $testBatch

Write-ColorText "OK Batch files created successfully" $Green
Write-Host ""
Write-ColorText "Setup completed! You can now use the Local File Organizer." $Green