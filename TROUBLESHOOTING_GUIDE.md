# Local File Organizer - Troubleshooting Guide

## Table of Contents
- [Quick Diagnostics](#quick-diagnostics)
- [Common Installation Issues](#common-installation-issues)
- [Runtime Errors](#runtime-errors)
- [Performance Issues](#performance-issues)
- [Model-Related Problems](#model-related-problems)
- [File Processing Issues](#file-processing-issues)
- [Platform-Specific Issues](#platform-specific-issues)
- [Recovery Procedures](#recovery-procedures)

## Quick Diagnostics

### First Step: Run Diagnostic Tools
```bash
# Comprehensive diagnostic
python diagnostic.py

# Simple diagnostic
python diagnostic_simple.py

# Quick test with sample data
python start.py
```

### Check System Status
```bash
# Verify Python version
python --version

# Check conda environment
conda list

# Verify Tesseract installation
tesseract --version

# Check available disk space
df -h  # Linux/macOS
dir    # Windows
```

## Common Installation Issues

### Issue 1: Python Version Mismatch
**Symptoms**:
```
RuntimeError: This package requires Python 3.12 or higher
```

**Solutions**:
```bash
# Check current Python version
python --version

# Install Python 3.12
# macOS:
brew install python@3.12

# Ubuntu/Debian:
sudo apt-get install python3.12

# Windows: Download from python.org

# Create new environment with correct version
conda create --name local_file_organizer python=3.12
conda activate local_file_organizer
```

### Issue 2: Conda Environment Issues
**Symptoms**:
```
CommandNotFoundError: Your shell has not been configured to use 'conda'
```

**Solutions**:
```bash
# Initialize conda
conda init

# Restart terminal, then:
conda activate local_file_organizer

# If environment doesn't exist:
conda create --name local_file_organizer python=3.12
conda activate local_file_organizer
```

### Issue 3: Nexa SDK Installation Failures
**Symptoms**:
```
ERROR: Could not build wheels for nexaai
ERROR: Failed building wheel for llama-cpp-python
```

**Solutions**:
```bash
# Clear pip cache
pip cache purge

# Install build dependencies
# macOS:
xcode-select --install
brew install cmake

# Ubuntu/Linux:
sudo apt-get install build-essential cmake

# Windows: Install Visual Studio Build Tools

# Retry installation
pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/cpu --extra-index-url https://pypi.org/simple --no-cache-dir
```

### Issue 4: Tesseract OCR Not Found
**Symptoms**:
```
pytesseract.pytesseract.TesseractNotFoundError: tesseract is not installed
```

**Solutions**:
```bash
# Install Tesseract
# macOS:
brew install tesseract

# Ubuntu/Linux:
sudo apt-get install tesseract-ocr

# Windows: Download from GitHub and add to PATH
# https://github.com/UB-Mannheim/tesseract/wiki

# Set custom path if needed:
export TESSERACT_CMD='/usr/local/bin/tesseract'
```

### Issue 5: Missing Dependencies
**Symptoms**:
```
ModuleNotFoundError: No module named 'fitz'
ModuleNotFoundError: No module named 'docx'
```

**Solutions**:
```bash
# Install missing packages individually
pip install PyMuPDF          # for 'fitz'
pip install python-docx      # for 'docx'
pip install python-pptx      # for PowerPoint support
pip install pandas openpyxl  # for Excel support
pip install nltk rich        # for text processing and UI

# Or install all at once
pip install -r requirements.txt
```

## Runtime Errors

### Issue 6: Model Download Failures
**Symptoms**:
```
Error: Failed to download model Llama3.2-3B-Instruct
ConnectionError: Unable to connect to model repository
```

**Solutions**:
```bash
# Check internet connection
ping google.com

# Check available disk space (models need 5-8GB)
df -h

# Try manual model download
python -c "
from nexa.gguf import NexaTextInference
model = NexaTextInference('Llama3.2-3B-Instruct:q3_K_M')
"

# Clear model cache and retry
rm -rf ~/.nexa/models/*  # Linux/macOS
# Windows: Delete contents of C:\Users\[username]\.nexa\models\

# Use different model location
export NEXA_MODEL_PATH=/path/to/custom/models
```

### Issue 7: Memory Errors
**Symptoms**:
```
RuntimeError: CUDA out of memory
MemoryError: Unable to allocate array
OutOfMemoryError: CUDA out of memory
```

**Solutions**:
```bash
# Use CPU-only mode
pip uninstall nexaai
pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/cpu

# Reduce batch size (modify main.py)
# Change max_new_tokens from 3000 to 1000

# Close other applications
# Monitor memory usage:
# Linux/macOS: htop or top
# Windows: Task Manager

# Add virtual memory (swap)
# Linux: sudo swapon -s
```

### Issue 8: Permission Errors
**Symptoms**:
```
PermissionError: [Errno 13] Permission denied: '/path/to/file'
OSError: [Errno 1] Operation not permitted
```

**Solutions**:
```bash
# Check file permissions
ls -la /path/to/directory

# Fix permissions
chmod -R 755 /path/to/directory
chown -R $USER /path/to/directory

# Windows: Run as administrator
# Right-click on terminal and "Run as administrator"

# Check if files are in use
lsof /path/to/file  # Linux/macOS
```

### Issue 9: Path-Related Errors
**Symptoms**:
```
FileNotFoundError: [Errno 2] No such file or directory
OSError: [Errno 22] Invalid argument (Windows)
```

**Solutions**:
```bash
# Use absolute paths
python main.py
# Enter full path: /home/user/documents instead of ~/documents

# Windows: Use forward slashes or escape backslashes
C:/Users/Name/Documents  # Good
C:\\Users\\Name\\Documents  # Good
C:\Users\Name\Documents    # May cause issues

# Check for special characters in paths
# Avoid: spaces, unicode characters, special symbols
# Prefer: underscores, hyphens, alphanumeric characters
```

## Performance Issues

### Issue 10: Slow Processing
**Symptoms**:
- AI analysis takes extremely long
- Application appears frozen
- High memory usage

**Solutions**:
```bash
# Use faster organization modes
# Type-based: Fastest, no AI processing
# Date-based: Fast, no AI processing
# Content-based: Slowest, full AI analysis

# Reduce file count per batch
# Process directories with fewer files first

# Monitor system resources
htop  # Linux/macOS
# Check CPU and memory usage

# Use CPU-only mode if GPU is slow
# Some integrated GPUs are slower than CPU

# Enable silent mode for batch processing
# Reduces console output overhead
```

### Issue 11: Large File Handling
**Symptoms**:
```
MemoryError: cannot allocate memory for array
ValueError: file too large to process
```

**Solutions**:
```bash
# Check file sizes before processing
find /path -name "*.pdf" -size +100M  # Find files > 100MB

# Skip large files temporarily
# Modify file_utils.py to add size checks

# Increase virtual memory
# Linux: sudo fallocate -l 4G /swapfile
# sudo swapon /swapfile

# Process large files individually
# Use type or date organization for large collections
```

## Model-Related Problems

### Issue 12: Model Loading Failures
**Symptoms**:
```
RuntimeError: Failed to load model
ValueError: Model format not supported
```

**Solutions**:
```bash
# Clear model cache
rm -rf ~/.nexa/models/*

# Download models manually
python -c "
from nexa.gguf import NexaTextInference, NexaVLMInference
NexaTextInference('Llama3.2-3B-Instruct:q3_K_M')
NexaVLMInference('llava-v1.6-vicuna-7b:q4_0')
"

# Check model compatibility
python -c "
import platform
print(f'Platform: {platform.platform()}')
print(f'Architecture: {platform.architecture()}')
"

# Try different model quantization
# q3_K_M (smaller, faster) vs q4_0 (larger, better quality)
```

### Issue 13: Inconsistent AI Results
**Symptoms**:
- Same files get different categories each run
- Generated filenames are inconsistent
- Folder organization varies

**Solutions**:
```bash
# AI models have inherent randomness
# This is normal behavior for creative AI models

# Use date or type organization for consistency
# These modes are fully deterministic

# For content mode:
# Results will vary but should be reasonable
# Multiple runs may yield different but valid organization schemes
```

## File Processing Issues

### Issue 14: Unsupported File Types
**Symptoms**:
```
WARNING: Unsupported file format: .xyz
Skipping file: unknown_format.abc
```

**Solutions**:
```bash
# Check supported formats:
# Images: .png, .jpg, .jpeg, .gif, .bmp, .tiff
# Docs: .txt, .md, .pdf, .doc, .docx
# Spreadsheets: .xls, .xlsx, .csv
# Presentations: .ppt, .pptx

# Files not in supported formats will be skipped
# This is expected behavior, not an error

# To include unsupported files:
# Use type-based organization
# They'll be placed in "others" folder
```

### Issue 15: Corrupted File Handling
**Symptoms**:
```
Error reading file: corrupt_document.pdf
PIL.UnidentifiedImageError: cannot identify image
```

**Solutions**:
```bash
# Check file integrity
file /path/to/suspicious_file

# Repair if possible
# PDFs: Use PDF repair tools
# Images: Try opening in image editor

# Skip corrupted files
# Application will continue processing other files
# Check operation_log.txt for skipped files

# Remove corrupted files from input directory
find /path -name "*.pdf" -exec file {} \; | grep -i "corrupt"
```

## Platform-Specific Issues

### Windows Issues

**Issue 16: Path Length Limits**
**Symptoms**:
```
OSError: [Errno 36] File name too long
```
**Solutions**:
- Use shorter directory names
- Enable long path support in Windows
- Move files closer to root directory

**Issue 17: Antivirus Interference**
**Symptoms**:
- Slow file processing
- Permission errors
- Unexpected program termination

**Solutions**:
- Add exclusion for project directory
- Temporarily disable real-time scanning
- Use Windows Defender exclusions

### macOS Issues

**Issue 18: Gatekeeper/Security**
**Symptoms**:
```
"python" cannot be opened because the developer cannot be verified
```
**Solutions**:
```bash
# Allow from Security & Privacy settings
# Or run:
xattr -d com.apple.quarantine /path/to/python
```

**Issue 19: Homebrew Path Issues**
**Symptoms**:
- Tesseract not found
- Python version conflicts

**Solutions**:
```bash
# Add Homebrew to PATH
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Use Homebrew Python
which python3.12
/opt/homebrew/bin/python3.12
```

### Linux Issues

**Issue 20: Missing System Libraries**
**Symptoms**:
```
ImportError: libGL.so.1: cannot open shared object file
```
**Solutions**:
```bash
# Install missing libraries
sudo apt-get install libgl1-mesa-glx
sudo apt-get install libglib2.0-0
sudo apt-get install python3.12-dev

# For headless servers:
export MPLBACKEND=Agg
```

## Recovery Procedures

### Procedure 1: Complete Reset
```bash
# 1. Backup any important data
cp -r organized_folder organized_folder_backup

# 2. Remove conda environment
conda remove --name local_file_organizer --all

# 3. Clear model cache
rm -rf ~/.nexa/models/*

# 4. Restart from installation
conda create --name local_file_organizer python=3.12
conda activate local_file_organizer
# Follow setup guide from step 3
```

### Procedure 2: Partial Reset (Keep Models)
```bash
# 1. Keep models but reinstall packages
pip freeze > current_packages.txt
pip uninstall -r current_packages.txt -y
pip install -r requirements.txt

# 2. Reinstall Nexa SDK
pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/cpu
```

### Procedure 3: Emergency File Recovery
```bash
# If organization went wrong:
# 1. Check if hard links were used (no data loss)
ls -la organized_folder/

# 2. Files should show link count > 1
# Original files are still safe

# 3. Remove organized folder if needed
rm -rf organized_folder/

# 4. Original files remain untouched in input directory
```

## Getting Additional Help

### Check Application Logs
```bash
# Silent mode log
cat operation_log.txt

# System logs (Linux)
journalctl -f

# Check for core dumps
ls -la /tmp/core*
```

### Gather Diagnostic Information
```bash
# Create diagnostic report
python diagnostic.py > diagnostic_report.txt 2>&1
python --version >> diagnostic_report.txt
conda list >> diagnostic_report.txt
uname -a >> diagnostic_report.txt  # Linux/macOS
systeminfo >> diagnostic_report.txt  # Windows
```

### Community Resources
- **GitHub Issues**: [Local File Organizer Issues](https://github.com/QiuYannnn/Local-File-Organizer/issues)
- **Nexa SDK Issues**: [Nexa SDK Repository](https://github.com/NexaAI/nexa-sdk/issues)
- **Documentation**: Check README.md and other guides

### Creating Bug Reports
When reporting issues, include:
1. Error message (full stack trace)
2. Operating system and version
3. Python version (`python --version`)
4. Output from `python diagnostic.py`
5. Steps to reproduce the issue
6. Sample files (if safe to share)

---

**Remember**: The application is designed to be safe - it never deletes or overwrites your original files. In worst case scenarios, your data remains protected.