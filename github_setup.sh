#!/bin/bash

# GitHub Repository Setup for Emotional Avatar Demo
# Run this from: ~/hk-projects/nimbs/emotional-avatar-demo/

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

echo -e "${BLUE}🐙 Setting up Git repository and GitHub integration${NC}"
echo "========================================================="

# Check if we're in the right directory
if [ ! -f "demo_runner.py" ] || [ ! -d "src" ]; then
    print_error "Not in the emotional-avatar-demo directory!"
    echo "Please run this script from: ~/hk-projects/nimbs/emotional-avatar-demo/"
    exit 1
fi

print_info "Current directory: $(pwd)"

# Initialize git repository
print_info "Initializing Git repository..."

if [ -d ".git" ]; then
    print_warning "Git repository already exists"
else
    git init
    print_status "Git repository initialized"
fi

# Configure git if not already configured
print_info "Checking Git configuration..."

if ! git config user.name > /dev/null 2>&1; then
    read -p "Enter your Git username: " git_username
    git config user.name "$git_username"
    print_status "Git username set to: $git_username"
else
    print_status "Git username already configured: $(git config user.name)"
fi

if ! git config user.email > /dev/null 2>&1; then
    read -p "Enter your Git email: " git_email
    git config user.email "$git_email"
    print_status "Git email set to: $git_email"
else
    print_status "Git email already configured: $(git config user.email)"
fi

# Create/update .gitignore
print_info "Creating comprehensive .gitignore..."

cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
env/
venv/
ENV/
env.bak/
venv.bak/
.venv/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Streamlit
.streamlit/

# Data files (optional - uncomment if files are large)
# data/models/*.h5
# data/models/*.pkl
# data/assets/music/*.mp3
# data/assets/music/*.wav
# data/assets/videos/*.mp4

# Temporary files
*.tmp
*.temp
.cache/
.pytest_cache/

# Jupyter Notebooks
.ipynb_checkpoints

# Coverage reports
htmlcov/
.coverage
.coverage.*
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
EOF

print_status ".gitignore created"

# Create a comprehensive README for GitHub
print_info "Creating GitHub README..."

cat > README.md << 'EOF'
# 🤖 Emotional Avatar Demo

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Streamlit](https://img.shields.io/badge/Streamlit-1.28+-red.svg)](https://streamlit.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Real-time emotional state visualization and adaptive avatar system with ML-driven personalization.

![Demo Screenshot](https://via.placeholder.com/800x400/4CAF50/FFFFFF?text=Emotional+Avatar+Demo)

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Virtual environment (recommended)

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/emotional-avatar-demo.git
cd emotional-avatar-demo

# Create virtual environment (optional but recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the demo
streamlit run demo_runner.py
```

### 🌐 Access the Demo
Open your browser and navigate to: **http://localhost:8501**

## 📋 Features

### ✅ **Currently Implemented**
- **📊 Real-time Emotion Visualization**: 7 emotional metrics displayed in interactive graphs
- **🧠 BCI Data Simulation**: Pre-processed emotional state data with realistic patterns
- **🎭 Dynamic Avatar States**: Avatar expressions that adapt to emotional states
- **💓 Biometric Monitoring**: Heart rate and breathing pattern visualization
- **🎵 Contextual Music Recommendations**: Audio suggestions based on emotional state
- **🎮 Interactive Dashboard**: Streamlit-based control panel

### 🔄 **Emotional Metrics Tracked**
1. **Engagement** (0.0-1.0)
2. **Excitement** (0.0-1.0) 
3. **Stress** (0.0-1.0)
4. **Relaxation** (0.0-1.0)
5. **Interest** (0.0-1.0)
6. **Heart Rate** (50-120 BPM)
7. **Breathing Rate** (10-25 breaths/min)

### 🎯 **Demo Scenarios**
- **😐 Neutral**: Baseline emotional state
- **😰 Stressed**: High-pressure work scenario
- **😌 Relaxed**: Meditation/calm state
- **🤩 Excited**: High energy/enthusiasm

## 🏗️ Architecture

```
emotional-avatar-demo/
├── 🚀 demo_runner.py              # Main entry point
├── 📁 src/                        # Source code
│   ├── ⚙️ config.py              # Configuration management
│   ├── 📊 data/                   # BCI simulation & ML processing
│   ├── 🎭 avatar/                 # Avatar control system
│   ├── 🎵 audio/                  # Audio & voice systems
│   ├── 🖥️ ui/                     # User interface components
│   └── 🛠️ utils/                  # Utility functions
├── 📂 data/                       # Data storage
│   ├── 🧠 bci_samples/           # Pre-processed BCI data
│   ├── 🤖 models/                 # ML models
│   └── 🎨 assets/                 # Media assets
├── ⚙️ demo_configs/               # Demo configurations
├── 🧪 tests/                      # Test files
└── 📚 docs/                       # Documentation
```

## 🎮 Usage Guide

### Starting the Demo
1. **Launch**: Run `streamlit run demo_runner.py`
2. **Select Scenario**: Choose from neutral, stressed, relaxed, or excited states
3. **Observe**: Watch real-time emotional metrics and avatar adaptations
4. **Interact**: Use the control panel to modify settings

### Dashboard Components

#### 📊 **Emotional Metrics Panel**
- Real-time line charts for all 7 emotional metrics
- Current value displays with delta indicators
- Time-series visualization over 2-minute windows

#### 🎭 **Avatar State Display**
- Current avatar expression based on emotional state
- Color-coded status indicators
- Expression mapping logic visualization

#### 🎵 **Audio Adaptation**
- Context-aware music recommendations
- Emotional state-based audio selection
- Dynamic soundscape suggestions

#### 🎮 **Control Panel**
- Scenario switching (neutral/stressed/relaxed/excited)
- Real-time data refresh controls
- Configuration adjustments

## 📊 BCI Data Format

The demo uses CSV files with the following structure:

```csv
timestamp,engagement,excitement,stress,relaxation,interest,heart_rate,breath_rate
0,0.75,0.45,0.23,0.67,0.82,68,16
1,0.73,0.48,0.25,0.65,0.80,70,17
2,0.71,0.51,0.27,0.63,0.78,72,18
```

### Data Specifications
- **Sampling Rate**: 1 Hz (1 sample per second)
- **Session Duration**: 2 minutes (120 samples)
- **Emotional Range**: 0.0 to 1.0 for psychological metrics
- **Physiological Range**: Realistic BPM and breathing rates

## 🔧 Development

### Project Setup for Contributors

```bash
# Clone and setup
git clone https://github.com/YOUR_USERNAME/emotional-avatar-demo.git
cd emotional-avatar-demo

# Install development dependencies
pip install -r requirements.txt
pip install pytest black flake8

# Run tests
python test_setup.py

# Code formatting
black src/

# Linting
flake8 src/
```

### Adding New Features

1. **New BCI Scenarios**: Add CSV files to `data/bci_samples/`
2. **Avatar Expressions**: Extend `src/avatar/` components
3. **Audio Integration**: Enhance `src/audio/` modules
4. **UI Components**: Modify `src/ui/dashboard.py`

## 🚀 Deployment Options

### Local Development
```bash
streamlit run demo_runner.py
```

### Docker Deployment
```bash
# Build image
docker build -t emotional-avatar-demo .

# Run container
docker run -p 8501:8501 emotional-avatar-demo
```

### Cloud Deployment
- **Streamlit Cloud**: Direct GitHub integration
- **Heroku**: Web app deployment
- **Google Cloud Platform**: Scalable hosting
- **AWS**: EC2 or ECS deployment

## 🎯 Roadmap

### Phase 1: Core Demo ✅
- [x] Basic emotional visualization
- [x] BCI data simulation
- [x] Avatar state mapping
- [x] Interactive dashboard

### Phase 2: Enhanced Features 🚧
- [ ] Real-time webcam emotion detection
- [ ] Voice interaction (TTS/STT)
- [ ] Advanced avatar animations
- [ ] Music integration with audio files

### Phase 3: ML Integration 📋
- [ ] Custom emotion classification models
- [ ] Real BCI hardware integration
- [ ] Predictive emotional modeling
- [ ] Personalization algorithms

### Phase 4: Production 📋
- [ ] Multi-user support
- [ ] Cloud-based deployment
- [ ] Mobile app integration
- [ ] Enterprise features

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Streamlit** for the amazing web framework
- **OpenCV** for computer vision capabilities
- **Plotly** for interactive visualizations
- **NumPy & Pandas** for data processing

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/emotional-avatar-demo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/emotional-avatar-demo/discussions)
- **Email**: your.email@example.com

---

<div align="center">
  <strong>Built with ❤️ for emotional AI research and development</strong>
</div>
EOF

print_status "README.md created"

# Create LICENSE file
print_info "Creating LICENSE file..."

cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Emotional Avatar Demo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

print_status "LICENSE file created"

# Create GitHub workflow for CI/CD (optional)
print_info "Creating GitHub Actions workflow..."

mkdir -p .github/workflows

cat > .github/workflows/demo-test.yml << 'EOF'
name: Demo Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        python-version: [3.8, 3.9, "3.10"]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v3
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install pandas numpy
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
    
    - name: Run setup test
      run: |
        python test_setup.py
    
    - name: Test Streamlit app
      run: |
        # Test that the app can be imported without errors
        python -c "import sys; sys.path.append('src'); from ui.dashboard import main; print('✅ Dashboard import successful')"
EOF

print_status "GitHub Actions workflow created"

# Add all files to git
print_info "Adding files to Git repository..."

git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    print_warning "No changes to commit"
else
    print_info "Committing changes..."
    git commit -m "Initial commit: Complete Emotional Avatar Demo with GitHub integration

Features:
- Real-time emotional visualization dashboard
- BCI data simulation with 4 realistic scenarios
- Avatar state mapping and expression system
- Interactive Streamlit interface
- Comprehensive documentation and setup scripts
- GitHub Actions CI/CD workflow
- MIT License

Ready for development and deployment!"

    print_status "Changes committed to Git"
fi

# Setup GitHub remote (interactive)
echo
echo -e "${BLUE}🐙 GitHub Repository Setup${NC}"
echo "================================="

read -p "Do you want to connect to a GitHub repository? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "To create and connect to GitHub repository:"
    echo "1. Go to https://github.com/new"
    echo "2. Create a new repository named: emotional-avatar-demo"
    echo "3. Don't initialize with README (we already have one)"
    echo
    
    read -p "Enter your GitHub username: " github_username
    read -p "Enter repository name [emotional-avatar-demo]: " repo_name
    repo_name=${repo_name:-emotional-avatar-demo}
    
    github_url="https://github.com/${github_username}/${repo_name}.git"
    
    print_info "Setting up GitHub remote..."
    
    # Check if remote already exists
    if git remote get-url origin > /dev/null 2>&1; then
        print_warning "Remote 'origin' already exists. Updating URL..."
        git remote set-url origin "$github_url"
    else
        git remote add origin "$github_url"
    fi
    
    print_status "GitHub remote configured: $github_url"
    
    echo
    echo -e "${YELLOW}📤 To push to GitHub, run:${NC}"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo
    
    read -p "Push to GitHub now? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Pushing to GitHub..."
        
        git branch -M main
        
        if git push -u origin main; then
            print_status "Successfully pushed to GitHub!"
            echo
            echo -e "${GREEN}🎉 Your repository is now available at:${NC}"
            echo "   https://github.com/${github_username}/${repo_name}"
        else
            print_error "Failed to push to GitHub. Please check your credentials and repository access."
            echo
            echo -e "${YELLOW}Manual push instructions:${NC}"
            echo "   git branch -M main"
            echo "   git push -u origin main"
        fi
    fi
else
    print_info "Skipping GitHub setup. You can connect later with:"
    echo "   git remote add origin https://github.com/USERNAME/REPO.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
fi

# Final summary
echo
echo -e "${GREEN}🎉 Git and GitHub setup completed!${NC}"
echo "=============================================="
echo
echo -e "${BLUE}📁 Repository status:${NC}"
git status --short

echo
echo -e "${BLUE}🚀 Next steps:${NC}"
echo "1. Test the demo:"
echo "   streamlit run demo_runner.py"
echo
echo "2. Start developing:"
echo "   - Add new BCI scenarios in data/bci_samples/"
echo "   - Enhance avatar system in src/avatar/"
echo "   - Improve dashboard in src/ui/dashboard.py"
echo
echo "3. Share your work:"
echo "   - Repository is ready for collaboration"
echo "   - Contributors can clone and start immediately"
echo "   - GitHub Actions will test all changes"
echo

if git remote get-url origin > /dev/null 2>&1; then
    echo -e "${BLUE}🌍 GitHub repository:${NC} $(git remote get-url origin)"
fi
