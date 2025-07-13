#!/usr/bin/env python3
"""
Emotional Avatar Demo - Main Entry Point
Usage: streamlit run demo_runner.py
"""

import sys
from pathlib import Path

# Add src to Python path
sys.path.insert(0, str(Path(__file__).parent / "src"))

# Import and run the dashboard
if __name__ == "__main__":
    from ui.dashboard import main
    main()
