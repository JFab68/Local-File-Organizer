# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Local File Organizer, an AI-powered file management system that runs entirely on your device for privacy. It uses local AI models via the Nexa SDK to analyze and organize files into meaningful directory structures.

The application can organize files in three modes:
1. **By Content** - Uses AI to analyze file contents and create semantic categories
2. **By Date** - Organizes files by modification date (year/month structure)
3. **By Type** - Groups files by file type with subfolders

## Running the Application

### Environment Setup
```bash
# Activate the conda environment
conda activate local_file_organizer

# Install dependencies
pip install -r requirements.txt

# Install Nexa SDK (CPU version)
pip install nexaai --prefer-binary --index-url https://nexaai.github.io/nexa-sdk/whl/cpu --extra-index-url https://pypi.org/simple --no-cache-dir
```

### Run the Main Application
```bash
python main.py
```

### Diagnostic Tools
```bash
# Simple diagnostic for environment
python diagnostic_simple.py

# Full diagnostic
python diagnostic.py
```

## Core Architecture

The application follows a modular architecture with these key components:

### Main Entry Point
- `main.py` - Primary application entry point with user interface and workflow orchestration

### Processing Modules
- `data_processing_common.py` - Shared utilities for file operations, metadata generation, and file organization
- `text_data_processing.py` - Handles text-based files (.txt, .docx, .pdf, .md, .xlsx, .csv, .ppt)
- `image_data_processing.py` - Processes image files using vision-language models (.png, .jpg, .gif, etc.)
- `file_utils.py` - File I/O operations, content extraction, and directory tree utilities

### Support Modules
- `output_filter.py` - Context manager for filtering model initialization output
- `start.py` - Alternative entry point

### AI Model Integration
The application uses two local AI models via Nexa SDK:
- **LLaVA-v1.6 (Vicuna-7B)** - Vision-language model for image analysis (`llava-v1.6-vicuna-7b:q4_0`)
- **Llama3.2-3B-Instruct** - Text model for content analysis and metadata generation (`Llama3.2-3B-Instruct:q3_K_M`)

Models are initialized lazily in `main.py` when content-based organization is selected.

### Processing Flow
1. **File Collection** - Recursively collects file paths from input directory
2. **Type Separation** - Separates files into images and text-based files
3. **Content Analysis** - Uses appropriate AI models to analyze file contents
4. **Metadata Generation** - Generates descriptions, folder names, and filenames
5. **Operation Planning** - Creates file operation plan (copy/link operations)
6. **Execution** - Performs file organization with progress tracking

### Key Features
- **Dry Run Mode** - Preview organization structure before committing changes
- **Silent Mode** - Log operations to file instead of console output
- **Progress Tracking** - Rich progress bars for file processing
- **Multiple Organization Strategies** - Content, date, or type-based organization
- **File Type Support** - Images, documents, spreadsheets, presentations, PDFs

## Dependencies

Key dependencies include:
- `nexa` - Nexa SDK for local AI models
- `rich` - Progress bars and console formatting
- `nltk` - Natural language processing for text analysis
- `PyMuPDF` (fitz) - PDF processing
- `python-docx` - Word document processing
- `pandas` - Spreadsheet processing
- `python-pptx` - PowerPoint processing
- `Pillow` - Image processing
- `pytesseract` - OCR capabilities

## File Organization Strategy

The application creates organized directory structures:

### Content Mode
Files are categorized by AI-analyzed content into semantic folders with descriptive filenames.

### Date Mode
```
output_folder/
├── 2023/
│   ├── January/
│   ├── February/
│   └── ...
└── 2024/
    └── ...
```

### Type Mode
```
output_folder/
├── image_files/
├── text_files/
│   ├── plain_text_files/
│   ├── doc_files/
│   ├── pdf_files/
│   └── xls_files/
└── others/
```