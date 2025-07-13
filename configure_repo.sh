#!/bin/bash

# Configure existing GitHub repository for Emotional Avatar Demo
# Use existing nimbs repo: https://github.com/vbsamuel/nimbs

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

echo -e "${BLUE}🔧 Configuring existing nimbs repository${NC}"
echo "============================================="

# Verify we're in the right directory
if [ ! -f "demo_runner.py" ] || [ ! -d "src" ]; then
    print_error "Not in the emotional-avatar-demo directory!"
    echo "Please run this from: ~/hk-projects/nimbs/emotional-avatar-demo/"
    exit 1
fi

print_info "Current directory: $(pwd)"

# Set up SSH remote for existing nimbs repository
GITHUB_USER="vbsamuel"
REPO_NAME="nimbs"
SSH_URL="git@github.com:${GITHUB_USER}/${REPO_NAME}.git"

print_info "Configuring SSH remote for: https://github.com/${GITHUB_USER}/${REPO_NAME}"

# Update the remote URL to use SSH
print_info "Setting remote URL to SSH..."
git remote set-url origin "$SSH_URL"

print_status "Remote URL updated to: $SSH_URL"

# Test SSH connection
print_info "Testing SSH connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    print_status "SSH authentication successful!"
else
    print_warning "SSH test shows authentication, but let's continue..."
fi

# Check current git status
print_info "Current git status:"
git status --porcelain

# Check if we have commits to push
if [ -n "$(git log origin/main..HEAD 2>/dev/null)" ] || ! git rev-parse --verify origin/main >/dev/null 2>&1; then
    print_info "Local commits found or remote branch doesn't exist. Preparing to push..."
    
    # Ensure we're on main branch
    git branch -M main
    
    # Since this will be a subdirectory in the nimbs repo, let's create a clear structure
    print_info "This will push the emotional-avatar-demo as a project within nimbs repository..."
    
    read -p "Continue with push to nimbs repository? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Pushing to GitHub..."
        
        # Try to push
        if git push -u origin main; then
            print_status "Successfully pushed to GitHub!"
            echo
            echo -e "${GREEN}🎉 Your emotional avatar demo is now on GitHub!${NC}"
            echo "Repository: https://github.com/${GITHUB_USER}/${REPO_NAME}"
            echo "Demo location: https://github.com/${GITHUB_USER}/${REPO_NAME}/tree/main/emotional-avatar-demo"
        else
            print_warning "Push failed. This might be because the remote has different history."
            echo
            print_info "Trying to resolve with force push (this will overwrite remote)..."
            read -p "Force push? This will overwrite remote content (y/N): " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git push --force-with-lease origin main
                print_status "Force push completed!"
            else
                print_info "Alternative: Pull remote changes first..."
                if git pull origin main --allow-unrelated-histories; then
                    print_info "Merged remote changes. Pushing again..."
                    git push origin main
                    print_status "Push successful after merge!"
                else
                    print_error "Merge failed. Manual resolution needed."
                fi
            fi
        fi
    else
        print_warning "Push cancelled. You can push later with: git push -u origin main"
    fi
else
    print_status "Repository is up to date with remote"
fi

echo
echo -e "${BLUE}📁 Repository structure in nimbs:${NC}"
echo "nimbs/"
echo "├── emotional-avatar-demo/          # Your new project"
echo "│   ├── demo_runner.py"
echo "│   ├── src/"
echo "│   ├── data/"
echo "│   └── ..."
echo "└── (other nimbs content)"

echo
echo -e "${BLUE}🚀 Quick start for others:${NC}"
echo "git clone git@github.com:${GITHUB_USER}/${REPO_NAME}.git"
echo "cd ${REPO_NAME}/emotional-avatar-demo"
echo "pip install -r requirements.txt"
echo "streamlit run demo_runner.py"

echo
echo -e "${BLUE}🔗 Repository links:${NC}"
echo "Main repo: https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "Demo folder: https://github.com/${GITHUB_USER}/${REPO_NAME}/tree/main/emotional-avatar-demo"
echo "Raw demo runner: https://github.com/${GITHUB_USER}/${REPO_NAME}/blob/main/emotional-avatar-demo/demo_runner.py"

# Create a quick deployment script for the nimbs repo structure
print_info "Creating deployment script for nimbs repository structure..."

cat > ../deploy_emotional_avatar.sh << 'EOF'
#!/bin/bash

# Deployment script for Emotional Avatar Demo within nimbs repository
# Run this from the nimbs root directory

echo "🤖 Deploying Emotional Avatar Demo from nimbs repository"
echo "======================================================="

# Check if we're in nimbs repo
if [ ! -d "emotional-avatar-demo" ]; then
    echo "❌ emotional-avatar-demo directory not found!"
    echo "Please run this from the nimbs repository root"
    exit 1
fi

cd emotional-avatar-demo

echo "📦 Installing dependencies..."
pip install -r requirements.txt

echo "🧪 Running setup test..."
python test_setup.py

if [ $? -eq 0 ]; then
    echo ""
    echo "🚀 Starting Emotional Avatar Demo..."
    echo "Opening browser at: http://localhost:8501"
    echo ""
    streamlit run demo_runner.py
else
    echo "❌ Setup test failed. Please check the installation."
    exit 1
fi
EOF

chmod +x ../deploy_emotional_avatar.sh

print_status "Deployment script created: ../deploy_emotional_avatar.sh"

# Create a README for the nimbs repo structure
print_info "Creating README for nimbs repository integration..."

cat > ../EMOTIONAL_AVATAR_README.md << 'EOF'
# 🤖 Emotional Avatar Demo in NIMBS

This directory contains the Emotional Avatar Demo project as part of the NIMBS repository.

## 🚀 Quick Start

From the nimbs repository root:

```bash
# Run the deployment script
./deploy_emotional_avatar.sh

# Or manually:
cd emotional-avatar-demo
pip install -r requirements.txt
streamlit run demo_runner.py
```

## 📁 Project Structure

```
nimbs/
├── emotional-avatar-demo/          # Emotional Avatar Demo project
│   ├── demo_runner.py             # Main entry point
│   ├── src/                       # Source code
│   ├── data/                      # BCI data and assets
│   ├── requirements.txt           # Dependencies
│   └── README.md                  # Project documentation
├── deploy_emotional_avatar.sh     # Quick deployment script
└── EMOTIONAL_AVATAR_README.md     # This file
```

## 🎯 Features

- **Real-time emotional visualization**: 7 metrics dashboard
- **BCI data simulation**: 4 realistic emotional scenarios
- **Avatar state mapping**: Dynamic expression changes
- **Interactive dashboard**: Streamlit-based interface

## 🔧 Development

The demo is a self-contained project within the nimbs repository:

- **Isolated dependencies**: Has its own requirements.txt
- **Independent deployment**: Can run standalone
- **Modular structure**: Easy to enhance and modify

## 📊 Demo Scenarios

- **Neutral**: Baseline emotional state
- **Stressed**: High-pressure work scenario  
- **Relaxed**: Meditation/calm state
- **Excited**: High energy/enthusiasm

## 🌐 Access

Once running, access the demo at: http://localhost:8501
EOF

print_status "Integration README created: ../EMOTIONAL_AVATAR_README.md"

echo
echo -e "${GREEN}🎉 Configuration completed!${NC}"
echo "==========================================="

echo
echo -e "${BLUE}✅ What's configured:${NC}"
echo "• SSH remote URL set to: $SSH_URL"
echo "• Local repository ready for nimbs integration"
echo "• Deployment script created for easy setup"
echo "• Documentation created for nimbs structure"

echo
echo -e "${BLUE}🚀 Test your demo:${NC}"
echo "streamlit run demo_runner.py"

echo
echo -e "${BLUE}🔗 Your repository:${NC}"
echo "https://github.com/${GITHUB_USER}/${REPO_NAME}"

# Show git remotes and status
echo
print_info "Git configuration:"
echo "Remote: $(git remote get-url origin)"
echo "Branch: $(git branch --show-current)"
echo "Status: $(git status --porcelain | wc -l) files changed"
