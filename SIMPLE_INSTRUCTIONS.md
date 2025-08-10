# SIMPLE STEP-BY-STEP INSTRUCTIONS

## STEP 1: Open Command Prompt
1. Press Windows Key + R
2. Type: `cmd`
3. Press Enter

## STEP 2: Navigate to the Folder
Copy and paste this EXACT command:
```
cd "C:\Users\johnf\VS Code Projects\Automated Fie Organizier\Local-File-Organizer"
```
Press Enter

## STEP 3: Test if Everything Works
Copy and paste this EXACT command:
```
python start.py
```
Press Enter

### What Should Happen:
- You should see "Local File Organizer - Quick Test"
- It should say "SUCCESS! The application is working correctly!"

## STEP 4: Run the Real Application
Copy and paste this EXACT command:
```
python main.py
```
Press Enter

### What Will Happen:
1. It asks if you want "silent mode" - Type: `no`
2. It asks for "directory to organize" - Type: `sample_data`
3. It asks for "output directory" - Just press Enter (uses default)
4. It asks which mode (1, 2, or 3):
   - Type `2` for Date mode (fastest)
   - Type `3` for Type mode (fast)
   - Type `1` for Content mode (slow, uses AI)
5. It shows you what it will do
6. It asks "proceed with changes" - Type: `yes`

## IF YOU GET STUCK:

### Problem: "Command not found" or "Python not recognized"
Try this instead:
```
py start.py
```

### Problem: "File not found"
Make sure you're in the right folder. Try:
```
dir
```
You should see files like "main.py" and "start.py"

### Problem: Any other error
Run this to check what's wrong:
```
python diagnostic_simple.py
```

## WHAT THE APP DOES:
- Takes messy files and organizes them into neat folders
- Can organize by date, by file type, or by content (using AI)
- Creates a new organized folder without touching your original files

## SIMPLE EXAMPLE:
Your messy folder:
```
my_files/
  - photo1.jpg
  - report.pdf
  - music.mp3
  - budget.xlsx
```

After organizing by TYPE:
```
organized_folder/
  - image_files/photo1.jpg
  - text_files/pdf_files/report.pdf
  - others/music.mp3
  - text_files/xls_files/budget.xlsx
```

That's it! Try Step 1-4 above and you'll have an organized file system!