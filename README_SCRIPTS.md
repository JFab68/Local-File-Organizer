# PowerShell Installation Scripts for Local File Organizer

This directory contains automated PowerShell scripts to handle installation and testing of the Local File Organizer application on Windows.

## Scripts Overview

### 🚀 Main Setup Script
**`setup.ps1`** - Complete automated installation
```powershell
.\setup.ps1
```
- Checks prerequisites (Python, Conda, Tesseract)
- Creates conda environment
- Installs Nexa SDK
- Installs all Python requirements
- Downloads NLTK data
- Runs verification tests
- Creates convenient batch files

**Parameters:**
- `-Force` - Recreate environment even if exists
- `-SkipEnvCheck` - Skip environment verification
- `-CondaPath "path"` - Specify custom conda path

### 🔍 Environment Verification
**`verify_environment.ps1`** - Check installation status
```powershell
.\verify_environment.ps1
```
- Comprehensive environment check
- Package verification
- NLTK data validation
- Project files check
- Detailed reporting

### ⚙️ Nexa SDK Installation
**`install_nexa.ps1`** - Install Nexa SDK with platform options
```powershell
.\install_nexa.ps1 -Platform cpu
```
- CPU version (default)
- CUDA version (`-Platform cuda`)
- Metal version (`-Platform metal`)
- Model initialization testing

### 📦 Requirements Installation
**`install_requirements.ps1`** - Install Python packages
```powershell
.\install_requirements.ps1
```
- Batch installation from requirements.txt
- Individual package installation
- Package verification
- NLTK data setup

**Parameters:**
- `-Force` - Reinstall all packages
- `-Individual` - Install packages one by one
- `-CondaEnv "name"` - Specify environment name

### 🧪 Testing Suite
**`test_application.ps1`** - Comprehensive testing
```powershell
.\test_application.ps1
```
- Environment testing
- Package import tests
- Model initialization
- Diagnostic script execution
- Sample data processing

**Parameters:**
- `-Quick` - Skip model initialization
- `-FullTest` - Run complete diagnostic suite
- `-SampleData` - Test with sample data
- `-Verbose` - Show detailed output

## Quick Start Batch Files

### 🎯 Run Application
**`run_organizer.bat`** - Double-click to start
- Activates conda environment
- Runs main.py
- User-friendly interface

### 🔧 Run Tests
**`test_organizer.bat`** - Double-click to test
- Activates conda environment
- Runs diagnostic tests
- Shows results

## Usage Examples

### Complete Fresh Installation
```powershell
# Run complete setup
.\setup.ps1

# Verify everything works
.\verify_environment.ps1

# Test the application
.\test_application.ps1 -Quick
```

### Fix Issues
```powershell
# Check what's wrong
.\verify_environment.ps1

# Reinstall requirements
.\install_requirements.ps1 -Force

# Reinstall Nexa SDK
.\install_nexa.ps1 -Platform cpu -Force
```

### Different Installation Options
```powershell
# Install with NVIDIA GPU support
.\install_nexa.ps1 -Platform cuda

# Force recreation of environment
.\setup.ps1 -Force

# Install requirements individually (slower but more reliable)
.\install_requirements.ps1 -Individual
```

### Testing Options
```powershell
# Quick test (skip model downloads)
.\test_application.ps1 -Quick

# Full comprehensive test
.\test_application.ps1 -FullTest -SampleData -Verbose

# Just verify environment
.\verify_environment.ps1
```

## Prerequisites

- **Windows 10/11**
- **PowerShell 5.1+** (pre-installed)
- **Python 3.8+** (you have Python 13 ✓)
- **Tesseract OCR** (you have this ✓)

## Execution Policy

If you get execution policy errors, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Troubleshooting

### Common Issues

1. **"Conda not found"**
   - Install Miniconda/Anaconda
   - Or specify path: `.\setup.ps1 -CondaPath "C:\path\to\conda.exe"`

2. **"Tesseract not found"**
   - Add Tesseract to PATH
   - Usually: `C:\Program Files\Tesseract-OCR`

3. **Package installation fails**
   - Try: `.\install_requirements.ps1 -Individual`
   - Check internet connection
   - Run as administrator if needed

4. **Model downloads fail**
   - Check internet connection
   - Models are large (several GB)
   - First run takes time

### Getting Help

1. **Check environment**: `.\verify_environment.ps1`
2. **Run diagnostics**: `.\test_application.ps1 -Verbose`  
3. **Force reinstall**: `.\setup.ps1 -Force`

## File Structure

```
Local-File-Organizer/
├── setup.ps1                    # Main setup script
├── verify_environment.ps1       # Environment verification
├── install_nexa.ps1             # Nexa SDK installer
├── install_requirements.ps1     # Requirements installer
├── test_application.ps1         # Test suite
├── run_organizer.bat            # Quick start batch
├── test_organizer.bat           # Quick test batch
└── README_SCRIPTS.md            # This file
```

## Success Indicators

✅ **Ready to use when:**
- All scripts show green checkmarks
- `.\test_application.ps1` passes all tests
- `run_organizer.bat` starts successfully
- Models download on first run

🎉 **Enjoy organizing your files with AI!**