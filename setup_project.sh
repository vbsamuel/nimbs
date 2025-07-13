#!/bin/bash

# Emotional Avatar Demo - Ubuntu Project Setup
# Run this from your nimbs directory: ~/hk-projects/nimbs/
# Usage: chmod +x setup_project.sh && ./setup_project.sh

set -e

PROJECT_NAME="emotional-avatar-demo"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

echo -e "${BLUE}🤖 Setting up Emotional Avatar Demo in nimbs directory${NC}"
echo "================================================================"

# Check current directory
CURRENT_DIR=$(basename "$PWD")
if [[ "$PWD" != *"nimbs"* ]]; then
    print_warning "Not in nimbs directory. Current: $PWD"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_info "Creating project in: $PWD/$PROJECT_NAME"

# Create project directory
if [ -d "$PROJECT_NAME" ]; then
    print_warning "Directory $PROJECT_NAME exists. Backing up..."
    mv "$PROJECT_NAME" "${PROJECT_NAME}_backup_$(date +%Y%m%d_%H%M%S)"
fi

mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

print_status "Created project directory: $PROJECT_NAME"

# Create folder structure
print_info "Creating folder structure..."

# Core directories
mkdir -p src/{data,avatar,audio,ui,utils}
mkdir -p data/{bci_samples,models,assets/{avatars,backgrounds,music}}
mkdir -p demo_configs
mkdir -p tests/{unit,integration}
mkdir -p logs
mkdir -p scripts
mkdir -p docs

print_status "Folder structure created"

# Create requirements.txt
print_info "Creating requirements.txt..."
cat > requirements.txt << 'EOF'
# Core dependencies for Emotional Avatar Demo
streamlit==1.28.0
opencv-python==4.8.0
pandas==2.1.0
numpy==1.24.0
scikit-learn==1.3.0
plotly==5.15.0
python-dotenv==1.0.0
pyyaml==6.0.1

# Audio processing
pygame==2.5.0
pyttsx3==2.90
SpeechRecognition==3.10.0
pyaudio==0.2.11

# Image processing
Pillow==10.0.0

# ML models (optional - for advanced features)
tensorflow==2.13.0
torch==2.1.0

# Development
pytest==7.4.0
black==23.7.0
flake8==6.0.0
EOF

print_status "requirements.txt created"

# Create .env.example
print_info "Creating environment configuration..."
cat > .env.example << 'EOF'
# Emotional Avatar Demo Configuration

# Demo Settings
DEMO_MODE=true
DEBUG=true
LOG_LEVEL=INFO

# Audio Settings
TTS_ENGINE=espeak
MUSIC_VOLUME=0.7

# Camera Settings
CAMERA_INDEX=0
CAMERA_WIDTH=640
CAMERA_HEIGHT=480

# Data Settings
BCI_SAMPLE_RATE=1.0
EMOTION_UPDATE_RATE=0.5
EOF

# Copy to actual .env
cp .env.example .env

print_status "Environment files created"

# Create main demo runner
print_info "Creating main demo files..."
cat > demo_runner.py << 'EOF'
#!/usr/bin/env python3
"""
Emotional Avatar Demo - Main Entry Point
Usage: streamlit run demo_runner.py
"""

import sys
from pathlib import Path

# Add src to Python path
sys.path.insert(0, str(Path(__file__).parent / "src"))

# Streamlit app
import streamlit as st

def main():
    st.set_page_config(
        page_title="🤖 Emotional Avatar Demo",
        page_icon="🤖",
        layout="wide"
    )
    
    st.title("🤖 Emotional Avatar Demo")
    st.markdown("---")
    
    st.info("🚀 Demo is ready! Run: `streamlit run demo_runner.py`")
    
    # Basic demo interface
    col1, col2, col3 = st.columns([2, 1, 1])
    
    with col1:
        st.subheader("📊 Emotion Metrics")
        st.write("Real-time emotion graphs will appear here")
        
    with col2:
        st.subheader("🎭 Avatar")
        st.write("Avatar display here")
        
    with col3:
        st.subheader("🎮 Controls")
        if st.button("Start Demo"):
            st.success("Demo started!")

if __name__ == "__main__":
    main()
EOF

chmod +x demo_runner.py

print_status "Main demo runner created"

# Create core config file
cat > src/config.py << 'EOF'
"""
Configuration for Emotional Avatar Demo
"""

import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Paths
    BASE_DIR = Path(__file__).parent.parent
    DATA_DIR = BASE_DIR / "data"
    ASSETS_DIR = DATA_DIR / "assets"
    LOGS_DIR = BASE_DIR / "logs"
    
    # Demo settings
    DEMO_MODE = os.getenv("DEMO_MODE", "true").lower() == "true"
    DEBUG = os.getenv("DEBUG", "true").lower() == "true"
    
    # BCI metrics
    BCI_METRICS = [
        "engagement", "excitement", "stress", "relaxation",
        "interest", "heart_rate", "breath_rate"
    ]
    
    # Avatar expressions
    AVATAR_EXPRESSIONS = [
        "neutral", "happy", "sad", "angry", "surprised", "relaxed", "stressed"
    ]

config = Config()
EOF

# Create __init__.py files
touch src/__init__.py
touch src/data/__init__.py
touch src/avatar/__init__.py
touch src/audio/__init__.py
touch src/ui/__init__.py
touch src/utils/__init__.py

print_status "Core Python files created"

# Create sample BCI data
print_info "Creating sample BCI data..."
python3 -c "
import pandas as pd
import numpy as np
from pathlib import Path

# Create sample scenarios
scenarios = {
    'neutral': {'stress': 0.3, 'engagement': 0.6, 'excitement': 0.4},
    'stressed': {'stress': 0.8, 'engagement': 0.7, 'excitement': 0.3},
    'relaxed': {'stress': 0.1, 'engagement': 0.4, 'excitement': 0.2},
    'excited': {'stress': 0.4, 'engagement': 0.9, 'excitement': 0.9}
}

for name, params in scenarios.items():
    data = {
        'timestamp': list(range(120)),  # 2 minutes
        'engagement': [max(0, min(1, params['engagement'] + np.random.uniform(-0.2, 0.2))) for _ in range(120)],
        'excitement': [max(0, min(1, params['excitement'] + np.random.uniform(-0.2, 0.2))) for _ in range(120)],
        'stress': [max(0, min(1, params['stress'] + np.random.uniform(-0.2, 0.2))) for _ in range(120)],
        'relaxation': [max(0, min(1, 1 - params['stress'] + np.random.uniform(-0.1, 0.1))) for _ in range(120)],
        'interest': [max(0, min(1, params['engagement'] + np.random.uniform(-0.15, 0.15))) for _ in range(120)],
        'heart_rate': [max(50, min(120, 72 + (params['stress'] - 0.3) * 30 + np.random.uniform(-8, 8))) for _ in range(120)],
        'breath_rate': [max(10, min(25, 16 + (params['stress'] - 0.3) * 6 + np.random.uniform(-2, 2))) for _ in range(120)]
    }
    
    df = pd.DataFrame(data)
    df.to_csv(f'data/bci_samples/{name}_state.csv', index=False)
    print(f'Created: {name}_state.csv')
"

print_status "Sample BCI data created"

# Create .gitignore
print_info "Creating .gitignore..."
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/

# Logs
logs/
*.log

# Environment
.env

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Data files (large)
data/models/*.h5
data/models/*.pkl
data/assets/music/*.mp3
data/assets/music/*.wav

# Temporary files
*.tmp
*.temp
.cache/
EOF

print_status ".gitignore created"

# Create README.md
print_info "Creating README.md..."
cat > README.md << 'EOF'
# 🤖 Emotional Avatar Demo

Real-time emotional state visualization and adaptive avatar system.

## 🚀 Quick Start

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Run demo
streamlit run demo_runner.py
```

## 📋 Features

- **Real-time emotion graphs**: 7 metrics visualization
- **BCI data simulation**: Pre-processed emotional states
- **Avatar expressions**: Dynamic avatar responses
- **Interactive dashboard**: Streamlit-based UI

## 🏗️ Project Structure

```
emotional-avatar-demo/
├── demo_runner.py              # Main entry point
├── src/                        # Source code
│   ├── data/                   # BCI simulation & ML
│   ├── avatar/                 # Avatar control
│   ├── audio/                  # Audio systems
│   └── ui/                     # User interface
├── data/                       # Data files
│   ├── bci_samples/           # Sample BCI data
│   ├── models/                # ML models
│   └── assets/                # Media assets
└── tests/                     # Test files
```

## 🎮 Usage

1. **Start Demo**: `streamlit run demo_runner.py`
2. **Open Browser**: http://localhost:8501
3. **Interact**: Use the dashboard controls

## 🔧 Development

```bash
# Install dev dependencies
pip install pytest black flake8

# Run tests
pytest tests/

# Format code
black src/

# Lint code
flake8 src/
```

## 📊 BCI Data Format

Sample emotional data structure:
```csv
timestamp,engagement,excitement,stress,relaxation,interest,heart_rate,breath_rate
0,0.75,0.45,0.23,0.67,0.82,68,16
```

## 🚀 Deployment

Ready for deployment on:
- Google Cloud Platform
- AWS
- Local servers

## 📝 License

MIT License - see LICENSE file for details.
EOF

print_status "README.md created"

# Create basic setup script
print_info "Creating setup script..."
cat > scripts/setup.sh << 'EOF'
#!/bin/bash

# Setup script for Emotional Avatar Demo

echo "🤖 Setting up Emotional Avatar Demo..."

# Check Python version
python3 --version

# Install requirements
echo "📦 Installing Python packages..."
pip install -r requirements.txt

echo "✅ Setup complete!"
echo "🚀 Run demo with: streamlit run demo_runner.py"
EOF

chmod +x scripts/setup.sh

print_status "Setup script created"

# Initialize git repository
print_info "Initializing Git repository..."
git init
git add .
git commit -m "Initial commit: Emotional Avatar Demo scaffolding"

print_status "Git repository initialized"

# Create GitHub setup instructions
cat > docs/github_setup.md << 'EOF'
# GitHub Setup Instructions

## 1. Create GitHub Repository

```bash
# Go to github.com and create new repository: emotional-avatar-demo
```

## 2. Connect Local Repository

```bash
# Add GitHub remote
git remote add origin https://github.com/YOUR_USERNAME/emotional-avatar-demo.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## 3. Clone on Other Machines

```bash
git clone https://github.com/YOUR_USERNAME/emotional-avatar-demo.git
cd emotional-avatar-demo
pip install -r requirements.txt
streamlit run demo_runner.py
```
EOF

print_status "GitHub setup instructions created"

# Final summary
echo
echo -e "${GREEN}🎉 Project setup completed successfully!${NC}"
echo "================================================================"
echo
echo -e "${BLUE}📁 Project location:${NC} $PWD"
echo -e "${BLUE}🚀 To start demo:${NC}"
echo "   cd $PROJECT_NAME"
echo "   pip install -r requirements.txt"
echo "   streamlit run demo_runner.py"
echo
echo -e "${BLUE}📚 Next steps:${NC}"
echo "   1. Run: pip install -r requirements.txt"
echo "   2. Test: streamlit run demo_runner.py"
echo "   3. Create GitHub repo and push"
echo "   4. Develop core features"
echo
echo -e "${BLUE}📋 Files created:${NC}"
echo "   ✅ Complete folder structure"
echo "   ✅ Python configuration files"
echo "   ✅ Sample BCI data"
echo "   ✅ Requirements and environment setup"
echo "   ✅ Git repository with initial commit"
echo "   ✅ Documentation and setup scripts"
echo

# Show tree structure if available
if command -v tree &> /dev/null; then
    echo -e "${BLUE}📂 Project structure:${NC}"
    tree -I '__pycache__|*.pyc|venv' -L 3
fi
