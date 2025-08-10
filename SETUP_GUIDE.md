# Local File Organizer - Complete Setup Guide

## Table of Contents
- [Prerequisites](#prerequisites)
- [System Requirements](#system-requirements)
- [Installation Process](#installation-process)
- [First-Time Setup](#first-time-setup)
- [Verification](#verification)
- [Common Issues](#common-issues)

## Prerequisites

### Required Software
- **Python 3.12+** - Download from [python.org](https://www.python.org/downloads/)
- **Git** - For cloning the repository
- **Conda** - Anaconda or Miniconda
- **Tesseract OCR** - For optical character recognition

### Platform-Specific Requirements

#### Windows
```bash
# Install Tesseract OCR
# Download from: https://github.com/UB-Mannheim/tesseract/wiki
# Add to PATH: C:\Program Files\Tesseract-OCR
```

#### macOS
```bash
# Install Tesseract OCR
brew install tesseract

# Install Python 3.12 if not available
brew install python@3.12
```

#### Linux (Ubuntu/Debian)
```bash
# Install Tesseract OCR
sudo apt-get update
sudo apt-get install tesseract-ocr

# Install Python 3.12
sudo apt-get install python3.12 python3.12-venv python3.12-dev
```

## System Requirements

### Minimum Requirements
- **RAM**: 8GB (16GB recommended for large file processing)
- **Storage**: 10GB free space (for AI models and processing)
- **CPU**: Multi-core processor (4+ cores recommended)

### Disk Space Breakdown
- Application files: ~50MB
- AI Models (downloaded on first run):
  - Llama3.2-3B: ~2-3GB
  - LLaVA-v1.6-7B: ~4-5GB
- Working space for file organization: Variable

## Installation Process

### Step 1: Clone Repository
```bash
# Clone the repository
git clone https://github.com/QiuYannnn/Local-File-Organizer.git
cd Local-File-Organizer
```

### Step 2: Create Python Environment
```bash
# Create conda environment
conda create --name local_file_organizer python=3.12
conda activate local_file_organizer
```

### Step 3: Install Nexa SDK

#### For CPU-only Installation
```bash
pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/cpu --extra-index-url https://pypi.org/simple --no-cache-dir
```

#### For GPU Support

**macOS (Metal)**
```bash
CMAKE_ARGS="-DGGML_METAL=ON -DSD_METAL=ON" pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/metal --extra-index-url https://pypi.org/simple --no-cache-dir
```

**CUDA (NVIDIA)**
```bash
CMAKE_ARGS="-DGGML_CUDA=ON" pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/cu121 --extra-index-url https://pypi.org/simple --no-cache-dir
```

**AMD ROCm**
```bash
CMAKE_ARGS="-DGGML_HIPBLAS=ON" pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/rocm --extra-index-url https://pypi.org/simple --no-cache-dir
```

### Step 4: Install Dependencies
```bash
# Install all required packages
pip install -r requirements.txt

# If the above fails, install individually:
pip install cmake pytesseract PyMuPDF python-docx pandas openpyxl xlrd nltk rich python-pptx
```

### Step 5: Verify Tesseract Installation
```bash
# Test Tesseract installation
tesseract --version
```

If Tesseract is not found, ensure it's in your system PATH.

## First-Time Setup

### Step 1: Download Required NLTK Data
The application will automatically download NLTK data on first run, but you can pre-download:

```python
python -c "
import nltk
nltk.download('punkt')
nltk.download('stopwords')
nltk.download('wordnet')
"
```

### Step 2: Verify Installation
```bash
# Run diagnostic script to check everything is working
python diagnostic.py

# Or run the simple diagnostic
python diagnostic_simple.py
```

### Step 3: Test with Sample Data
```bash
# Quick test with sample data
python start.py
```

## Verification

### Complete System Check
Run the comprehensive diagnostic:

```bash
python diagnostic.py
```

Expected output:
```
Local File Organizer Diagnostic Tool
==================================================

📋 Running Basic Imports test...
✅ PASS Basic Imports

📋 Running NLTK Data test...
✅ PASS NLTK Data

📋 Running File Processing test...
✅ PASS File Processing

📋 Running Minimal Test test...
✅ PASS Minimal Test

📋 Running Model Initialization test...
✅ PASS Model Initialization

==================================================
📊 DIAGNOSTIC SUMMARY
==================================================
✅ PASS Basic Imports
✅ PASS NLTK Data
✅ PASS File Processing
✅ PASS Minimal Test
✅ PASS Model Initialization

🎉 All tests passed! The application should work.
💡 Try running: python main.py
```

### Quick Functionality Test
```bash
# Run the main application
python main.py
```

You should see the main menu:
```
Would you like to enable silent mode? (yes/no): no
--------------------------------------------------
Enter the path of the directory you want to organize: [your path]
```

## Environment Variables (Optional)

Create a `.env` file for custom configuration:

```bash
# Model cache directory
MODEL_CACHE_DIR=./models

# Maximum file size for processing (bytes)
MAX_FILE_SIZE=100000000

# Tesseract path (if not in system PATH)
TESSERACT_CMD=/usr/local/bin/tesseract
```

## Common Issues

### Issue 1: Import Errors
```
ModuleNotFoundError: No module named 'nexa'
```
**Solution**: Ensure you're in the correct conda environment and Nexa SDK is installed.

### Issue 2: Tesseract Not Found
```
pytesseract.pytesseract.TesseractNotFoundError
```
**Solution**: Install Tesseract OCR and ensure it's in your PATH.

### Issue 3: Model Download Failures
```
Error: Failed to download model
```
**Solution**: 
- Check internet connection
- Ensure sufficient disk space
- Try running with administrator/sudo privileges

### Issue 4: Memory Errors
```
RuntimeError: CUDA out of memory
```
**Solution**:
- Use CPU-only installation
- Reduce batch size
- Close other memory-intensive applications

### Issue 5: Permission Errors
```
PermissionError: [Errno 13] Permission denied
```
**Solution**:
- Run with appropriate permissions
- Check file/folder ownership
- Ensure write permissions in output directory

## Next Steps

After successful installation:
1. Read the [User Guide](USER_GUIDE.md) for detailed usage instructions
2. Review [Troubleshooting Guide](TROUBLESHOOTING_GUIDE.md) for common issues
3. Check [Deployment Guide](DEPLOYMENT_GUIDE.md) for production setup

## Getting Help

If you encounter issues:
1. Run `python diagnostic.py` to identify problems
2. Check the troubleshooting section
3. Post issues on [GitHub](https://github.com/QiuYannnn/Local-File-Organizer/issues)
4. For Nexa SDK issues, visit [Nexa SDK Repository](https://github.com/NexaAI/nexa-sdk)

## Version Information

- **Application Version**: v0.0.2
- **Python Required**: 3.12+
- **Last Updated**: August 2024

---

**Note**: First-time setup may take 10-20 minutes due to AI model downloads. Ensure you have a stable internet connection and sufficient disk space.