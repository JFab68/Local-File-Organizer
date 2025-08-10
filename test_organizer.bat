@echo off
echo Local File Organizer - Test Suite
echo =================================

REM Find conda activation script
set CONDA_ACTIVATE=""
if exist "%USERPROFILE%\miniconda3\Scripts\activate.bat" set CONDA_ACTIVATE="%USERPROFILE%\miniconda3\Scripts\activate.bat"
if exist "%USERPROFILE%\anaconda3\Scripts\activate.bat" set CONDA_ACTIVATE="%USERPROFILE%\anaconda3\Scripts\activate.bat"

if %CONDA_ACTIVATE%=="" (
    echo Error: Could not find conda activation script
    echo Please ensure Anaconda or Miniconda is installed
    pause
    exit /b 1
)

echo Activating conda environment...
call %CONDA_ACTIVATE% local_file_organizer

echo Running diagnostic tests...
python diagnostic_simple.py

echo.
echo Tests completed. Press any key to close...
pause > nul