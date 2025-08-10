# Local File Organizer - Complete User Guide

## Table of Contents
- [Quick Start](#quick-start)
- [Organization Modes](#organization-modes)
- [Supported File Types](#supported-file-types)
- [Step-by-Step Usage](#step-by-step-usage)
- [Advanced Features](#advanced-features)
- [Examples & Use Cases](#examples--use-cases)
- [Tips & Best Practices](#tips--best-practices)

## Quick Start

### Basic Usage
```bash
# Activate your environment
conda activate local_file_organizer

# Run the application
python main.py
```

### Quick Test Run
```bash
# Test with sample data
python start.py
```

## Organization Modes

The Local File Organizer offers three distinct modes for organizing your files:

### 1. Content-Based Organization (AI-Powered)
**Best for**: Mixed file collections where content matters more than file type
- Uses AI to analyze file content
- Creates meaningful folder names based on content themes
- Generates descriptive filenames
- **Processing time**: Longer (AI analysis required)
- **Accuracy**: Highest for content relevance

**Example Output**:
```
organized_folder/
├── Financial/
│   └── 2023_Budget_Analysis.xlsx
├── Travel/
│   ├── Paris_Trip_Itinerary.docx
│   └── Hotel_Booking_Confirmation.pdf
└── Work_Projects/
    ├── Marketing_Strategy_Q4.pptx
    └── Team_Meeting_Notes.txt
```

### 2. Date-Based Organization
**Best for**: Archive organization, backup systems, photo libraries
- Organizes files by modification date
- Creates year/month folder structure
- Preserves original filenames
- **Processing time**: Fastest
- **Accuracy**: Perfect for chronological organization

**Example Output**:
```
organized_folder/
├── 2024/
│   ├── January/
│   │   ├── document1.pdf
│   │   └── photo1.jpg
│   └── February/
│       ├── report.docx
│       └── presentation.pptx
└── 2023/
    └── December/
        └── year_end_summary.xlsx
```

### 3. Type-Based Organization
**Best for**: Quick sorting, media libraries, development projects
- Groups files by file extension/type
- Creates standardized folder structure
- Preserves original filenames
- **Processing time**: Very fast
- **Accuracy**: Perfect for file type separation

**Example Output**:
```
organized_folder/
├── image_files/
│   ├── photo1.jpg
│   ├── logo.png
│   └── diagram.gif
├── text_files/
│   ├── doc_files/
│   │   ├── report.docx
│   │   └── notes.doc
│   ├── pdf_files/
│   │   └── manual.pdf
│   └── plain_text_files/
│       ├── readme.txt
│       └── changelog.md
└── others/
    └── unknown_file.xyz
```

## Supported File Types

### Images
- **Extensions**: `.png`, `.jpg`, `.jpeg`, `.gif`, `.bmp`, `.tiff`
- **AI Analysis**: Visual content recognition
- **Organization**: By visual themes (landscapes, people, objects)

### Documents
- **Word Documents**: `.doc`, `.docx`
- **PDFs**: `.pdf`
- **Text Files**: `.txt`, `.md`
- **AI Analysis**: Content summarization and categorization

### Spreadsheets
- **Excel**: `.xls`, `.xlsx`
- **CSV**: `.csv`
- **AI Analysis**: Data type and purpose identification

### Presentations
- **PowerPoint**: `.ppt`, `.pptx`
- **AI Analysis**: Topic and content theme recognition

### Planned Support (Future)
- **eBooks**: `.epub`, `.mobi`, `.azw`, `.azw3`
- **Audio**: `.mp3`, `.wav`, `.flac`
- **Video**: `.mp4`, `.avi`, `.mkv`

## Step-by-Step Usage

### Step 1: Launch Application
```bash
python main.py
```

### Step 2: Choose Silent Mode
```
Would you like to enable silent mode? (yes/no): 
```
- **No**: See real-time progress and details
- **Yes**: All output saved to `operation_log.txt`

### Step 3: Set Input Directory
```
Enter the path of the directory you want to organize: /path/to/messy/files
```
- Use absolute or relative paths
- Directory must exist and be readable
- Tip: Use tab completion in most terminals

### Step 4: Set Output Directory
```
Enter the path to store organized files: (press Enter for default)
```
- **Default**: Creates `organized_folder` next to input directory
- **Custom**: Specify any writable directory
- Directory will be created if it doesn't exist

### Step 5: Choose Organization Mode
```
Please choose the mode to organize your files:
1. By Content
2. By Date  
3. By Type
Enter 1, 2, or 3: 1
```

### Step 6: Review Proposed Changes (Dry Run)
The application shows you the proposed directory structure:
```
Proposed directory structure:
/path/to/organized_folder
├── Financial
│   └── Budget_Report_2024.xlsx
├── Travel
│   └── Vacation_Photos_Europe.jpg
└── Work
    └── Project_Proposal_Draft.docx

Would you like to proceed with these changes? (yes/no): 
```

### Step 7: Execute or Modify
- **Yes**: Apply the organization
- **No**: Choose different organization mode or exit

### Step 8: Organize Another Directory (Optional)
```
Would you like to organize another directory? (yes/no): 
```

## Advanced Features

### Dry Run Mode
Every operation starts with a dry run showing proposed changes before execution. This prevents unwanted modifications.

### Progress Tracking
Real-time progress bars show:
- File analysis progress
- Model initialization status
- Organization operation progress

### Silent Mode
- All output redirected to `operation_log.txt`
- Perfect for batch operations or scripts
- No interruption of console output

### Duplicate Handling
- Automatically detects filename conflicts
- Adds numeric suffixes: `document_1.pdf`, `document_2.pdf`
- Preserves all files without overwriting

### Error Recovery
- Continues processing even if individual files fail
- Detailed error reporting for troubleshooting
- Skips problematic files rather than stopping entirely

## Examples & Use Cases

### Use Case 1: Personal Document Organization

**Scenario**: You have a cluttered "Downloads" folder with mixed files.

**Input Directory Structure**:
```
Downloads/
├── IMG_20240315_142030.jpg
├── bank_statement_march.pdf
├── recipe_chocolate_cake.pdf
├── meeting_notes_0320.txt
├── vacation_booking.docx
└── tax_document_2023.pdf
```

**Command Sequence**:
```bash
python main.py
# Choose: No (to silent mode)
# Input: ./Downloads
# Output: (default)
# Mode: 1 (By Content)
# Proceed: yes
```

**Expected Result**:
```
organized_folder/
├── Financial/
│   ├── Bank_Statement_March.pdf
│   └── Tax_Document_2023.pdf
├── Food_Recipes/
│   └── Chocolate_Cake_Recipe.pdf
├── Travel/
│   └── Vacation_Booking_Confirmation.docx
├── Meeting_Notes/
│   └── Team_Meeting_March_20.txt
└── Photos/
    └── Spring_Outdoor_Scene.jpg
```

### Use Case 2: Photo Library Organization

**Scenario**: Organize photos by date for archival purposes.

**Command Sequence**:
```bash
python main.py
# Mode: 2 (By Date)
```

**Result**: Photos organized by year/month of creation or modification date.

### Use Case 3: Development Project Cleanup

**Scenario**: Sort mixed project files by type.

**Command Sequence**:
```bash
python main.py
# Mode: 3 (By Type)
```

**Result**: Clean separation of code files, documentation, images, and data files.

### Use Case 4: Batch Processing with Silent Mode

**Scenario**: Organize multiple directories without manual intervention.

```bash
# Create a simple script
echo '
import subprocess
import os

directories = ["./dir1", "./dir2", "./dir3"]
for directory in directories:
    if os.path.exists(directory):
        # Use type-based organization for speed
        subprocess.run(["python", "main.py", "--silent", "--mode", "type", "--input", directory])
' > batch_organize.py

python batch_organize.py
```

## Tips & Best Practices

### Before You Start
1. **Backup Important Files**: Always backup before organizing important data
2. **Test with Sample Data**: Use the sample_data directory to understand behavior
3. **Check Disk Space**: Ensure adequate space for organized files
4. **Close Other Applications**: Free up memory for AI model processing

### Choosing the Right Mode

**Use Content-Based When**:
- Files have meaningful content to analyze
- You want intelligent categorization
- Quality matters more than speed
- Mixed file types with related content

**Use Date-Based When**:
- Creating archives
- Organizing photos/media by time
- Legal/compliance document management
- You need chronological organization

**Use Type-Based When**:
- Quick file type separation needed
- Organizing development projects
- Creating media libraries
- Speed is more important than content analysis

### Performance Optimization
1. **Process Smaller Batches**: Break large collections into smaller groups
2. **Use Type/Date Modes**: For faster processing of large collections
3. **Close Memory-Heavy Apps**: During AI processing
4. **Use SSD Storage**: For faster file operations

### File Management Best Practices
1. **Review Dry Run Output**: Always check proposed changes
2. **Use Descriptive Input Paths**: Organize source directories first
3. **Monitor Log Files**: Check `operation_log.txt` in silent mode
4. **Regular Cleanup**: Periodically reorganize growing directories

### Troubleshooting Tips
1. **Run Diagnostics**: Use `python diagnostic.py` if issues occur
2. **Check File Permissions**: Ensure read/write access to directories
3. **Monitor Memory Usage**: Large files may require more RAM
4. **Update Dependencies**: Keep Nexa SDK and other packages current

## File Processing Details

### Content Analysis Process
1. **Text Extraction**: OCR for images, text parsing for documents
2. **Content Summarization**: AI generates concise summaries
3. **Category Detection**: Identifies main themes and topics
4. **Filename Generation**: Creates descriptive, human-readable names
5. **Folder Assignment**: Groups related content together

### AI Model Behavior
- **Conservative Approach**: Prefers broader categories when uncertain
- **Context Awareness**: Considers file relationships and patterns
- **Privacy Focused**: All processing happens locally
- **Deterministic Results**: Same files produce consistent organization

### File Handling Rules
- **Preserve Originals**: Uses hard links when possible (no duplication)
- **Safe Operations**: Never overwrites or deletes original files
- **Unicode Support**: Handles international filenames correctly
- **Permission Respect**: Maintains original file permissions

---

For technical issues, see the [Troubleshooting Guide](TROUBLESHOOTING_GUIDE.md).
For installation help, see the [Setup Guide](SETUP_GUIDE.md).
For production deployment, see the [Deployment Guide](DEPLOYMENT_GUIDE.md).