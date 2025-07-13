#!/bin/bash

# GitHub CLI Setup - Easiest authentication method
# This handles all authentication automatically

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

echo -e "${BLUE}🚀 GitHub CLI Setup - Easiest Method${NC}"
echo "======================================="

print_info "GitHub CLI handles authentication automatically - no tokens needed!"

# Check if GitHub CLI is already installed
if command -v gh &> /dev/null; then
    print_status "GitHub CLI is already installed"
    gh --version
else
    print_info "Installing GitHub CLI..."
    
    # Install GitHub CLI using official method
    type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
    
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
    
    print_status "GitHub CLI installed successfully!"
fi

echo
print_info "Now let's authenticate with GitHub..."
print_warning "This will open your browser for authentication"

# Authenticate with GitHub CLI
if gh auth login; then
    print_status "GitHub authentication successful!"
    
    # Check authentication status
    print_info "Authentication status:"
    gh auth status
    
    # Get the authenticated username
    github_username=$(gh api user --jq .login 2>/dev/null || echo "unknown")
    print_status "Authenticated as: $github_username"
    
else
    print_error "GitHub authentication failed. Let's try manual token method..."
    
    echo
    print_info "Manual token authentication:"
    echo "1. Go to: https://github.com/settings/tokens"
    echo "2. Generate new token with 'repo' scope"
    echo "3. Copy the token"
    
    read -p "Enter your Personal Access Token: " -s github_token
    echo
    
    if [ -n "$github_token" ]; then
        # Use token for authentication
        echo "$github_token" | gh auth login --with-token
        print_status "Manual token authentication successful!"
    else
        print_error "No token provided. Cannot proceed."
        exit 1
    fi
fi

echo
print_info "Now let's push to GitHub..."

# Check if repository exists
if gh repo view vbsamuel/nimbs >/dev/null 2>&1; then
    print_status "Repository vbsamuel/nimbs exists"
else
    print_warning "Repository doesn't exist. Creating it..."
    if gh repo create vbsamuel/nimbs --public --description "NIMBS project with Emotional Avatar Demo"; then
        print_status "Repository created successfully!"
    else
        print_error "Failed to create repository. It might already exist."
    fi
fi

# Set up the remote URL (GitHub CLI automatically configures HTTPS with token)
print_info "Configuring remote URL..."
git remote set-url origin https://github.com/vbsamuel/nimbs.git

# Now try to push
print_info "Pushing to GitHub..."
if git push -u origin main; then
    print_status "Successfully pushed to GitHub!"
    
    echo
    echo -e "${GREEN}🎉 SUCCESS! Your Emotional Avatar Demo is now on GitHub!${NC}"
    echo "================================================================"
    echo
    echo -e "${BLUE}🔗 Repository links:${NC}"
    echo "Main repository: https://github.com/vbsamuel/nimbs"
    echo "Demo folder: https://github.com/vbsamuel/nimbs/tree/main/emotional-avatar-demo"
    echo "Direct demo access: https://github.com/vbsamuel/nimbs/blob/main/emotional-avatar-demo/demo_runner.py"
    
    echo
    echo -e "${BLUE}🚀 Test your demo locally:${NC}"
    echo "streamlit run demo_runner.py"
    echo "→ Opens at: http://localhost:8501"
    
    echo
    echo -e "${BLUE}👥 For others to clone and run:${NC}"
    echo "git clone https://github.com/vbsamuel/nimbs.git"
    echo "cd nimbs/emotional-avatar-demo"
    echo "pip install -r requirements.txt"
    echo "streamlit run demo_runner.py"
    
    echo
    echo -e "${BLUE}📊 Demo features now live:${NC}"
    echo "• ✅ 7 real-time emotional metrics"
    echo "• ✅ 4 BCI scenarios (neutral, stressed, relaxed, excited)"
    echo "• ✅ Interactive Streamlit dashboard"
    echo "• ✅ Avatar state mapping"
    echo "• ✅ Music recommendations"
    echo "• ✅ Professional documentation"
    echo "• ✅ GitHub repository ready for collaboration"
    
    # Test repository access
    echo
    print_info "Verifying repository access..."
    if gh repo view vbsamuel/nimbs >/dev/null 2>&1; then
        print_status "Repository access confirmed!"
        
        # Show repository info
        print_info "Repository information:"
        gh repo view vbsamuel/nimbs --json name,description,url,visibility | jq -r '"Name: " + .name, "Description: " + .description, "URL: " + .url, "Visibility: " + .visibility'
    fi
    
else
    print_error "Push failed. Let's check what happened..."
    
    # Check git status
    print_info "Git status:"
    git status
    
    # Check remote
    print_info "Remote configuration:"
    git remote -v
    
    # Try alternative push methods
    echo
    print_info "Alternative solutions:"
    echo "1. Force push: git push --force-with-lease origin main"
    echo "2. Pull first: git pull origin main --allow-unrelated-histories"
    echo "3. Check repository permissions on GitHub"
    
    read -p "Try force push? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Attempting force push..."
        if git push --force-with-lease origin main; then
            print_status "Force push successful!"
        else
            print_error "Force push also failed. Manual intervention needed."
        fi
    fi
fi

echo
echo -e "${BLUE}🛠️  Development ready:${NC}"
echo "• Repository: Configured and accessible"
echo "• Authentication: GitHub CLI (permanent)"
echo "• Demo: Ready to run locally"
echo "• Collaboration: Others can clone and contribute"

print_status "Setup completed! 🎉"
