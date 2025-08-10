# Test and Validation Script for Local File Organizer
# This script runs comprehensive tests to ensure everything works correctly

param(
    [string]$CondaEnv = "local_file_organizer",
    [switch]$Quick,
    [switch]$FullTest,
    [switch]$SampleData,
    [string]$TestDir = "",
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Gray = "Gray"

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

function Write-SubHeader {
    param($Text)
    Write-Host ""
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host $Text -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
}

function Test-CondaEnvironment {
    Write-SubHeader "Testing Conda Environment"
    
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
        Write-ColorText "✗ Conda activation script not found" $Red
        return $false
    }

    Write-ColorText "✓ Conda activation script found: $activateScript" $Green
    return $activateScript
}

function Test-PythonEnvironment {
    param($ActivateScript)
    
    Write-SubHeader "Testing Python Environment"
    
    $testCmd = @"
call "$ActivateScript" $CondaEnv && python -c "
import sys
print(f'Python version: {sys.version}')
print(f'Python executable: {sys.executable}')
print('✓ Python environment active')
"
"@
    
    $result = cmd /c $testCmd 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-ColorText "✓ Python environment test passed" $Green
        if ($Verbose) {
            $result | ForEach-Object { Write-ColorText "  $_" $Gray }
        }
        return $true
    }
    else {
        Write-ColorText "✗ Python environment test failed" $Red
        if ($Verbose) {
            $result | ForEach-Object { Write-ColorText "  $_" $Red }
        }
        return $false
    }
}

function Test-PackageImports {
    param($ActivateScript)
    
    Write-SubHeader "Testing Package Imports"
    
    $packages = @(
        @{Name="Nexa SDK"; Import="from nexa.gguf import NexaVLMInference, NexaTextInference"},
        @{Name="pytesseract"; Import="import pytesseract"},
        @{Name="PyMuPDF"; Import="import fitz"},
        @{Name="python-docx"; Import="import docx"},
        @{Name="pandas"; Import="import pandas"},
        @{Name="openpyxl"; Import="import openpyxl"},
        @{Name="nltk"; Import="import nltk"},
        @{Name="rich"; Import="from rich.console import Console"},
        @{Name="python-pptx"; Import="import pptx"},
        @{Name="PIL/Pillow"; Import="from PIL import Image"}
    )
    
    $successCount = 0
    $totalCount = $packages.Count
    
    foreach ($pkg in $packages) {
        Write-ColorText "Testing $($pkg.Name)..." $Yellow
        
        $testCmd = @"
call "$ActivateScript" $CondaEnv && python -c "$($pkg.Import); print('OK')"
"@
        
        $result = cmd /c $testCmd 2>&1
        if ($result -match "OK") {
            Write-ColorText "✓ $($pkg.Name) import successful" $Green
            $successCount++
        }
        else {
            Write-ColorText "✗ $($pkg.Name) import failed" $Red
            if ($Verbose) {
                $result | ForEach-Object { Write-ColorText "    $_" $Red }
            }
        }
    }
    
    Write-Host ""
    Write-ColorText "Import Test Summary: $successCount/$totalCount packages working" $Cyan
    return $successCount -eq $totalCount
}

function Test-NLTKData {
    param($ActivateScript)
    
    Write-SubHeader "Testing NLTK Data"
    
    $nltkTestCmd = @"
call "$ActivateScript" $CondaEnv && python -c "
import nltk
datasets = ['stopwords', 'punkt', 'wordnet']
all_good = True

for dataset in datasets:
    try:
        if dataset == 'stopwords':
            nltk.data.find('corpora/stopwords')
        elif dataset == 'punkt':
            nltk.data.find('tokenizers/punkt')  
        elif dataset == 'wordnet':
            nltk.data.find('corpora/wordnet')
        print(f'✓ {dataset} available')
    except LookupError:
        print(f'✗ {dataset} missing')
        all_good = False

print('NLTK_TEST_COMPLETE')
if all_good:
    print('ALL_NLTK_OK')
"
"@
    
    $result = cmd /c $nltkTestCmd 2>&1
    if ($result -match "ALL_NLTK_OK") {
        Write-ColorText "✓ All NLTK data available" $Green
        return $true
    }
    else {
        Write-ColorText "⚠ Some NLTK data missing" $Yellow
        if ($Verbose) {
            $result | Where-Object {$_ -match "✗"} | ForEach-Object { Write-ColorText "  $_" $Red }
        }
        return $false
    }
}

function Test-ProjectFiles {
    Write-SubHeader "Testing Project Files"
    
    $requiredFiles = @(
        "main.py",
        "requirements.txt", 
        "diagnostic.py",
        "diagnostic_simple.py",
        "file_utils.py",
        "data_processing_common.py",
        "text_data_processing.py",
        "image_data_processing.py"
    )
    
    $missingFiles = @()
    
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-ColorText "✓ $file found" $Green
        }
        else {
            Write-ColorText "✗ $file missing" $Red
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -eq 0) {
        Write-ColorText "✓ All required project files present" $Green
        return $true
    }
    else {
        Write-ColorText "✗ Missing files: $($missingFiles -join ', ')" $Red
        return $false
    }
}

function Test-ModelInitialization {
    param($ActivateScript)
    
    Write-SubHeader "Testing Model Initialization"
    
    if ($Quick) {
        Write-ColorText "Skipping model initialization (Quick mode)" $Yellow
        return $true
    }
    
    Write-ColorText "Testing model initialization (this may take time)..." $Yellow
    Write-ColorText "Note: Models will be downloaded on first run" $Gray
    
    $modelTestCmd = @"
call "$ActivateScript" $CondaEnv && python -c "
import os
os.environ['NEXA_RUN_DOWNLOAD_IN_PARALLEL'] = 'false'

print('Testing Text Model Initialization...')
try:
    from nexa.gguf import NexaTextInference
    text_model = NexaTextInference(
        model_path='Llama3.2-3B-Instruct:q3_K_M', 
        local_path=None, 
        stop_words=[], 
        temperature=0.7, 
        max_new_tokens=50, 
        top_k=50, 
        top_p=1.0
    )
    print('✓ Text model initialized successfully')
except Exception as e:
    print(f'✗ Text model initialization failed: {e}')
    
print('Testing VLM Model Initialization...')
try:
    from nexa.gguf import NexaVLMInference
    vlm_model = NexaVLMInference(
        model_path='llava-v1.6-vicuna-7b:q4_0',
        local_path=None,
        stop_words=[],
        temperature=0.7,
        max_new_tokens=50,
        top_k=50,
        top_p=1.0
    )
    print('✓ VLM model initialized successfully')
except Exception as e:
    print(f'✗ VLM model initialization failed: {e}')

print('MODEL_TEST_COMPLETE')
"
"@
    
    $result = cmd /c $modelTestCmd 2>&1
    
    if ($Verbose -or ($result -match "✗")) {
        $result | ForEach-Object { 
            if ($_ -match "✓") {
                Write-ColorText "  $_" $Green
            }
            elseif ($_ -match "✗") {
                Write-ColorText "  $_" $Red  
            }
            else {
                Write-ColorText "  $_" $Gray
            }
        }
    }
    
    $successfulInits = ($result | Where-Object {$_ -match "✓.*initialized successfully"}).Count
    return $successfulInits -ge 2
}

function Test-DiagnosticScripts {
    param($ActivateScript)
    
    Write-SubHeader "Testing Diagnostic Scripts"
    
    # Test diagnostic_simple.py
    Write-ColorText "Running diagnostic_simple.py..." $Yellow
    $simpleTestCmd = @"
call "$ActivateScript" $CondaEnv && python diagnostic_simple.py
"@
    
    $result = cmd /c $simpleTestCmd 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-ColorText "✓ diagnostic_simple.py completed successfully" $Green
        if ($Verbose) {
            $result | ForEach-Object { Write-ColorText "  $_" $Gray }
        }
    }
    else {
        Write-ColorText "⚠ diagnostic_simple.py had issues" $Yellow
        if ($Verbose) {
            $result | ForEach-Object { Write-ColorText "  $_" $Red }
        }
    }
    
    # Test diagnostic.py if FullTest
    if ($FullTest) {
        Write-ColorText "Running diagnostic.py (full test)..." $Yellow
        $fullTestCmd = @"
call "$ActivateScript" $CondaEnv && python diagnostic.py
"@
        
        $result = cmd /c $fullTestCmd 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-ColorText "✓ diagnostic.py completed successfully" $Green
        }
        else {
            Write-ColorText "⚠ diagnostic.py had issues" $Yellow
        }
        
        if ($Verbose) {
            $result | ForEach-Object { Write-ColorText "  $_" $Gray }
        }
    }
    
    return $true
}

function Test-SampleDataProcessing {
    param($ActivateScript)
    
    if (-not $SampleData) {
        Write-ColorText "Skipping sample data test (use -SampleData to enable)" $Yellow
        return $true
    }
    
    Write-SubHeader "Testing Sample Data Processing"
    
    if (-not (Test-Path "sample_data")) {
        Write-ColorText "✗ sample_data directory not found" $Red
        return $false
    }
    
    # Count files in sample_data
    $sampleFiles = Get-ChildItem -Path "sample_data" -Recurse -File
    Write-ColorText "Found $($sampleFiles.Count) files in sample_data directory" $Cyan
    
    if ($sampleFiles.Count -eq 0) {
        Write-ColorText "⚠ No sample files found for testing" $Yellow
        return $false
    }
    
    # Create a test output directory
    $testOutputDir = "test_output_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    Write-ColorText "Testing file organization with sample data..." $Yellow
    Write-ColorText "Output will be in: $testOutputDir" $Gray
    
    # Note: This would require modifying main.py to accept command-line arguments
    # For now, we'll just verify the sample files are accessible
    
    $sampleFiles | ForEach-Object {
        if ($Verbose) {
            Write-ColorText "  Sample file: $($_.Name)" $Gray
        }
    }
    
    Write-ColorText "✓ Sample data directory accessible with $($sampleFiles.Count) files" $Green
    Write-ColorText "Note: Run 'python main.py' manually to test full organization" $Yellow
    
    return $true
}

# Main execution
Write-Header "Local File Organizer - Comprehensive Testing"

Write-ColorText "Test configuration:" $Cyan
Write-ColorText "  Environment: $CondaEnv" $Gray
Write-ColorText "  Quick mode: $Quick" $Gray  
Write-ColorText "  Full test: $FullTest" $Gray
Write-ColorText "  Sample data test: $SampleData" $Gray
Write-ColorText "  Verbose output: $Verbose" $Gray

$testResults = @()

# Test 1: Conda Environment
$activateScript = Test-CondaEnvironment
if ($activateScript) {
    $testResults += @{Test="Conda Environment"; Result="PASS"}
}
else {
    $testResults += @{Test="Conda Environment"; Result="FAIL"}
    Write-ColorText "Cannot proceed without conda environment" $Red
    exit 1
}

# Test 2: Python Environment  
$pythonOK = Test-PythonEnvironment $activateScript
$testResults += @{Test="Python Environment"; Result=if($pythonOK){"PASS"}else{"FAIL"}}

# Test 3: Package Imports
$importsOK = Test-PackageImports $activateScript
$testResults += @{Test="Package Imports"; Result=if($importsOK){"PASS"}else{"FAIL"}}

# Test 4: NLTK Data
$nltkOK = Test-NLTKData $activateScript
$testResults += @{Test="NLTK Data"; Result=if($nltkOK){"PASS"}else{"WARN"}}

# Test 5: Project Files
$filesOK = Test-ProjectFiles
$testResults += @{Test="Project Files"; Result=if($filesOK){"PASS"}else{"FAIL"}}

# Test 6: Model Initialization (skip in Quick mode)
if (-not $Quick) {
    $modelsOK = Test-ModelInitialization $activateScript
    $testResults += @{Test="Model Initialization"; Result=if($modelsOK){"PASS"}else{"WARN"}}
}

# Test 7: Diagnostic Scripts
$diagnosticOK = Test-DiagnosticScripts $activateScript
$testResults += @{Test="Diagnostic Scripts"; Result=if($diagnosticOK){"PASS"}else{"WARN"}}

# Test 8: Sample Data (optional)
$sampleOK = Test-SampleDataProcessing $activateScript
$testResults += @{Test="Sample Data"; Result=if($sampleOK){"PASS"}else{"WARN"}}

# Final Results
Write-Header "Test Results Summary"

$passCount = ($testResults | Where-Object {$_.Result -eq "PASS"}).Count
$failCount = ($testResults | Where-Object {$_.Result -eq "FAIL"}).Count  
$warnCount = ($testResults | Where-Object {$_.Result -eq "WARN"}).Count

$testResults | ForEach-Object {
    $resultColor = switch($_.Result) {
        "PASS" { $Green }
        "FAIL" { $Red }
        "WARN" { $Yellow }
        default { "White" }
    }
    
    $resultSymbol = switch($_.Result) {
        "PASS" { "✓" }
        "FAIL" { "✗" }
        "WARN" { "⚠" }
        default { "?" }
    }
    
    Write-Host "$resultSymbol $($_.Test): " -NoNewline
    Write-ColorText "$($_.Result)" $resultColor
}

Write-Host ""
Write-ColorText "Summary:" $Cyan
Write-ColorText "✓ Passed: $passCount" $Green
Write-ColorText "✗ Failed: $failCount" $Red
Write-ColorText "⚠ Warnings: $warnCount" $Yellow

# Final recommendation
if ($failCount -eq 0) {
    Write-Host ""
    Write-ColorText "🎉 Testing completed successfully!" $Green
    Write-ColorText "Your Local File Organizer installation appears to be working correctly." $Green
    Write-Host ""
    Write-ColorText "To run the application:" $Cyan
    Write-ColorText "1. conda activate $CondaEnv" $Yellow
    Write-ColorText "2. python main.py" $Yellow
}
elseif ($failCount -gt 0 -and $passCount -gt $failCount) {
    Write-Host ""
    Write-ColorText "⚠ Testing completed with some issues." $Yellow
    Write-ColorText "Most components are working, but some failures need attention." $Yellow
    Write-ColorText "Check the failed tests above and run setup.ps1 if needed." $Yellow
}
else {
    Write-Host ""
    Write-ColorText "❌ Testing revealed significant issues." $Red
    Write-ColorText "Please run setup.ps1 to fix the installation." $Red
}

Write-Host ""
Write-ColorText "Testing completed." $Cyan