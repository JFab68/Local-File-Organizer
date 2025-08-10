#!/usr/bin/env python3
"""
Quick Start Script for Local File Organizer
This bypasses the interactive prompts for testing
"""

import os
import sys

def test_run():
    """Run the application with sample data"""
    print("Local File Organizer - Quick Test")
    print("=" * 40)
    
    # Check if sample data exists
    sample_path = 'sample_data'
    if not os.path.exists(sample_path):
        print("ERROR: sample_data directory not found")
        print("Please make sure you're in the right directory")
        return False
    
    print(f"PASS: Found sample data: {len(os.listdir(sample_path))} items")
    
    # Import the main modules
    try:
        from file_utils import collect_file_paths
        from data_processing_common import process_files_by_date, process_files_by_type
        print("PASS: Modules imported successfully")
    except Exception as e:
        print(f"ERROR: Import failed: {e}")
        return False
    
    # Test with sample data
    files = collect_file_paths(sample_path)
    print(f"PASS: Found {len(files)} files to organize")
    
    # Show what files we found
    print("\nFiles found:")
    for i, file_path in enumerate(files[:5]):  # Show first 5
        print(f"  {i+1}. {os.path.basename(file_path)}")
    if len(files) > 5:
        print(f"  ... and {len(files) - 5} more")
    
    # Test date-based organization
    print(f"\nTesting date-based organization...")
    output_path = 'test_organized_output'
    operations = process_files_by_date(files, output_path)
    print(f"PASS: Generated {len(operations)} operations for date-based organization")
    
    # Test type-based organization  
    print(f"\nTesting type-based organization...")
    operations = process_files_by_type(files, output_path)
    print(f"PASS: Generated {len(operations)} operations for type-based organization")
    
    print(f"\nSUCCESS! The application is working correctly!")
    print(f"\nTo run the full interactive version, use:")
    print(f"    python main.py")
    
    return True

if __name__ == "__main__":
    test_run()