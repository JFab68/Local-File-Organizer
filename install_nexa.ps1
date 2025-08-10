# Nexa SDK Installation Script for Local File Organizer
# This script handles the specific installation of Nexa SDK with various options

param(
    [ValidateSet("cpu", "metal", "cuda")]
    [string]$Platform = "cpu",
    [switch]$Force,
    [string]$CondaEnv = "local_file_organizer"
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

Write-Header "Nexa SDK Installation"

# Detect platform if not specified
if ($Platform -eq "cpu") {
    Write-ColorText "Auto-detecting optimal platform..." $Yellow
    
    # Check for NVIDIA GPU
    try {
        $nvidiaInfo = nvidia-smi 2>$null
        if ($nvidiaInfo) {
            Write-ColorText "NVIDIA GPU detected. Consider using -Platform cuda for better performance." $Yellow
        }
    }
    catch {
        # No NVIDIA GPU or nvidia-smi not available
    }
    
    # Check if on macOS (though this is Windows script, keeping for completeness)
    if ($env:OS -notmatch "Windows") {
        Write-ColorText "Non-Windows system detected. Consider using -Platform metal if on macOS." $Yellow
    }
}

Write-ColorText "Installing Nexa SDK for platform: $Platform" $Cyan

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
    Write-ColorText "Make sure Anaconda or Miniconda is installed" $Red
    exit 1
}

Write-ColorText "Using conda activation script: $activateScript" $Yellow

# Check if environment exists
Write-ColorText "Checking if conda environment '$CondaEnv' exists..." $Yellow
$envExists = conda env list 2>&1 | Select-String $CondaEnv
if (-not $envExists) {
    Write-ColorText "✗ Conda environment '$CondaEnv' not found" $Red
    Write-ColorText "Create it first with: conda create -n $CondaEnv python=3.12 -y" $Yellow
    exit 1
}

# Uninstall existing Nexa SDK if Force is specified
if ($Force) {
    Write-ColorText "Removing existing Nexa SDK installation..." $Yellow
    $uninstallCmd = @"
call "$activateScript" $CondaEnv && pip uninstall nexaai -y
"@
    cmd /c $uninstallCmd
}

# Install based on platform
Write-ColorText "Installing Nexa SDK for $Platform..." $Yellow

switch ($Platform) {
    "cpu" {
        Write-ColorText "Installing CPU version of Nexa SDK..." $Yellow
        $installCmd = @"
call "$activateScript" $CondaEnv && pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/cpu --extra-index-url https://pypi.org/simple --no-cache-dir
"@
    }
    
    "metal" {
        Write-ColorText "Installing Metal (macOS GPU) version of Nexa SDK..." $Yellow
        Write-ColorText "Note: This is optimized for macOS. On Windows, consider using 'cpu' or 'cuda'" $Yellow
        $installCmd = @"
call "$activateScript" $CondaEnv && set CMAKE_ARGS=-DGGML_METAL=ON -DSD_METAL=ON && pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/metal --extra-index-url https://pypi.org/simple --no-cache-dir
"@
    }
    
    "cuda" {
        Write-ColorText "Installing CUDA (NVIDIA GPU) version of Nexa SDK..." $Yellow
        Write-ColorText "Note: Requires NVIDIA GPU and CUDA toolkit" $Yellow
        $installCmd = @"
call "$activateScript" $CondaEnv && pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/cuda --extra-index-url https://pypi.org/simple --no-cache-dir
"@
    }
}

# Execute installation
try {
    cmd /c $installCmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorText "✓ Nexa SDK installed successfully" $Green
    }
    else {
        Write-ColorText "✗ Installation failed with exit code $LASTEXITCODE" $Red
        exit 1
    }
}
catch {
    Write-ColorText "✗ Installation failed: $($_.Exception.Message)" $Red
    exit 1
}

# Verify installation
Write-Header "Verifying Installation"

Write-ColorText "Testing Nexa SDK import..." $Yellow
$testCmd = @"
call "$activateScript" $CondaEnv && python -c "
try:
    from nexa.gguf import NexaVLMInference, NexaTextInference
    print('✓ Nexa SDK imported successfully')
    print('✓ VLM and Text inference classes available')
except ImportError as e:
    print(f'✗ Import failed: {e}')
    exit(1)
"
"@

cmd /c $testCmd

if ($LASTEXITCODE -eq 0) {
    Write-ColorText "✓ Nexa SDK verification passed" $Green
}
else {
    Write-ColorText "✗ Nexa SDK verification failed" $Red
    Write-ColorText "Try reinstalling with -Force parameter" $Yellow
    exit 1
}

# Test model initialization (quick test)
Write-ColorText "Testing model initialization (this may download models)..." $Yellow
$modelTestCmd = @"
call "$activateScript" $CondaEnv && python -c "
try:
    import os
    os.environ['NEXA_RUN_DOWNLOAD_IN_PARALLEL'] = 'false'
    
    print('Testing text model...')
    from nexa.gguf import NexaTextInference
    text_model = NexaTextInference(model_path='Llama3.2-3B-Instruct:q3_K_M', local_path=None, stop_words=[], temperature=0.7, max_new_tokens=50, top_k=50, top_p=1.0)
    print('✓ Text model initialized successfully')
    
    print('Testing VLM model...')
    from nexa.gguf import NexaVLMInference  
    vlm_model = NexaVLMInference(model_path='llava-v1.6-vicuna-7b:q4_0', local_path=None, stop_words=[], temperature=0.7, max_new_tokens=50, top_k=50, top_p=1.0)
    print('✓ VLM model initialized successfully')
    
    print('✓ All models ready for use')
except Exception as e:
    print(f'⚠ Model initialization warning: {e}')
    print('Models will be downloaded on first use')
"
"@

cmd /c $modelTestCmd

Write-Header "Installation Complete"

Write-ColorText "Nexa SDK installation completed!" $Green
Write-Host ""
Write-ColorText "Platform: $Platform" $Cyan
Write-ColorText "Environment: $CondaEnv" $Cyan
Write-Host ""
Write-ColorText "To use the models:" $Yellow
Write-ColorText "1. Activate environment: conda activate $CondaEnv" $Green
Write-ColorText "2. Run your application: python main.py" $Green
Write-Host ""
Write-ColorText "Note: Models will be automatically downloaded on first use." $Yellow
Write-ColorText "Initial downloads may take several minutes depending on your connection." $Yellow

# Additional platform-specific notes
switch ($Platform) {
    "cuda" {
        Write-Host ""
        Write-ColorText "CUDA Installation Notes:" $Cyan
        Write-ColorText "- Ensure NVIDIA GPU drivers are up to date" $Yellow
        Write-ColorText "- CUDA toolkit should be installed" $Yellow
        Write-ColorText "- First run may take longer due to CUDA initialization" $Yellow
    }
    
    "metal" {
        Write-Host ""
        Write-ColorText "Metal Installation Notes:" $Cyan  
        Write-ColorText "- This build is optimized for macOS Metal" $Yellow
        Write-ColorText "- On Windows, consider using 'cpu' or 'cuda' instead" $Yellow
    }
    
    "cpu" {
        Write-Host ""
        Write-ColorText "CPU Installation Notes:" $Cyan
        Write-ColorText "- Processing will be slower than GPU versions" $Yellow
        Write-ColorText "- Consider upgrading to GPU version if available" $Yellow
    }
}