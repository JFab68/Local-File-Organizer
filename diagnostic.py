#!/usr/bin/env python3
"""
Local File Organizer Diagnostic Script
Run this to identify and fix common issues
"""

import os
import sys
import traceback
from pathlib import Path

def test_basic_imports():
    """Test all required imports"""
    print("Testing basic imports...")
    try:
        import nltk
        import pytesseract
        import fitz
        import docx
        import pandas as pd
        from pptx import Presentation
        from PIL import Image
        from nexa.gguf import NexaVLMInference, NexaTextInference
        from rich.progress import Progress
        print("PASS: All imports successful")
        return True
    except Exception as e:
        print(f"FAIL: Import failed: {e}")
        return False

def test_nltk_data():
    """Ensure NLTK data is downloaded"""
    print("🔍 Testing NLTK data...")
    import nltk
    required_data = ['punkt', 'stopwords', 'wordnet']
    missing = []
    
    for data in required_data:
        try:
            if data == 'punkt':
                nltk.data.find('tokenizers/punkt')
            elif data == 'stopwords':
                nltk.data.find('corpora/stopwords')
            elif data == 'wordnet':
                nltk.data.find('corpora/wordnet')
        except:
            missing.append(data)
    
    if missing:
        print(f"⚠️  Missing NLTK data: {missing}")
        print("   Downloading...")
        for data in missing:
            nltk.download(data, quiet=True)
        print("✅ NLTK data downloaded")
    else:
        print("✅ NLTK data available")
    return True

def test_file_processing():
    """Test file reading capabilities"""
    print("🔍 Testing file processing...")
    try:
        from file_utils import read_file_data, collect_file_paths
        
        # Test with sample data
        sample_path = 'sample_data'
        if os.path.exists(sample_path):
            files = collect_file_paths(sample_path)
            print(f"✅ Found {len(files)} files in sample_data")
            
            # Test reading a few files
            for file_path in files[:3]:
                try:
                    content = read_file_data(file_path)
                    if content:
                        print(f"✅ Successfully read {os.path.basename(file_path)}")
                    else:
                        print(f"⚠️  Could not read content from {os.path.basename(file_path)}")
                except Exception as e:
                    print(f"❌ Error reading {os.path.basename(file_path)}: {e}")
        else:
            print("⚠️  sample_data directory not found")
        
        return True
    except Exception as e:
        print(f"❌ File processing test failed: {e}")
        traceback.print_exc()
        return False

def test_model_initialization():
    """Test AI model initialization"""
    print("🔍 Testing AI model initialization...")
    try:
        from nexa.gguf import NexaVLMInference, NexaTextInference
        from output_filter import filter_specific_output
        
        print("   Initializing text model...")
        with filter_specific_output():
            text_inference = NexaTextInference(
                model_path="Llama3.2-3B-Instruct:q3_K_M",
                local_path=None,
                stop_words=[],
                temperature=0.5,
                max_new_tokens=100,  # Reduced for testing
                top_k=3,
                top_p=0.3,
                profiling=False
            )
        print("✅ Text model initialized successfully")
        
        # Test a simple completion
        print("   Testing text completion...")
        response = text_inference.create_completion("Hello, this is a test.")
        if response and 'choices' in response:
            print("✅ Text model completion works")
        else:
            print("⚠️  Text model completion returned unexpected format")
        
        return True
        
    except Exception as e:
        print(f"❌ Model initialization failed: {e}")
        traceback.print_exc()
        return False

def create_minimal_test():
    """Create a minimal working test"""
    print("🔍 Creating minimal test with sample data...")
    try:
        from file_utils import collect_file_paths, separate_files_by_type
        from data_processing_common import process_files_by_date, process_files_by_type
        
        sample_path = 'sample_data'
        if not os.path.exists(sample_path):
            print("❌ sample_data directory not found")
            return False
        
        files = collect_file_paths(sample_path)
        print(f"✅ Collected {len(files)} files")
        
        # Test date-based organization (no AI needed)
        print("   Testing date-based organization...")
        output_path = 'test_output'
        operations = process_files_by_date(files, output_path)
        print(f"✅ Generated {len(operations)} file operations")
        
        # Test type-based organization (no AI needed)
        print("   Testing type-based organization...")
        operations = process_files_by_type(files, output_path)
        print(f"✅ Generated {len(operations)} file operations")
        
        print("✅ Minimal test completed successfully")
        return True
        
    except Exception as e:
        print(f"❌ Minimal test failed: {e}")
        traceback.print_exc()
        return False

def main():
    """Run all diagnostic tests"""
    print("Local File Organizer Diagnostic Tool")
    print("=" * 50)
    
    tests = [
        ("Basic Imports", test_basic_imports),
        ("NLTK Data", test_nltk_data),
        ("File Processing", test_file_processing),
        ("Minimal Test", create_minimal_test),
        ("Model Initialization", test_model_initialization),
    ]
    
    results = []
    for name, test_func in tests:
        print(f"\n📋 Running {name} test...")
        try:
            success = test_func()
            results.append((name, success))
        except Exception as e:
            print(f"❌ {name} test crashed: {e}")
            results.append((name, False))
    
    print("\n" + "=" * 50)
    print("📊 DIAGNOSTIC SUMMARY")
    print("=" * 50)
    
    all_passed = True
    for name, success in results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {name}")
        if not success:
            all_passed = False
    
    if all_passed:
        print("\n🎉 All tests passed! The application should work.")
        print("💡 Try running: python main.py")
    else:
        print("\n⚠️  Some tests failed. Check the errors above.")
        print("💡 Try the fixes suggested for each failed test.")
    
    return all_passed

if __name__ == "__main__":
    main()