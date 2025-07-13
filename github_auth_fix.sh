#!/bin/bash

# GitHub Authentication Fix for Emotional Avatar Demo
# Fixes authentication issues and sets up proper GitHub connection

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

echo -e "${BLUE}🔐 GitHub Authentication Fix${NC}"
echo "================================="

print_info "Current remote URL: $(git remote get-url origin 2>/dev/null || echo 'No remote set')"

echo
echo -e "${YELLOW}GitHub now requires Personal Access Token (PAT) for authentication.${NC}"
echo "Here are your options:"
echo

echo -e "${BLUE}Option 1: Create a Personal Access Token (Recommended)${NC}"
echo "1. Go to: https://github.com/settings/tokens"
echo "2. Click 'Generate new token' → 'Generate new token (classic)'"
echo "3. Set expiration (30-90 days recommended)"
echo "4. Select scopes: ✅ repo (full control of private repositories)"
echo "5. Click 'Generate token'"
echo "6. Copy the token (you won't see it again!)"
echo

echo -e "${BLUE}Option 2: Use SSH (More secure, no password needed)${NC}"
echo "1. Generate SSH key: ssh-keygen -t ed25519 -C \"your.email@example.com\""
echo "2. Add to SSH agent: ssh-add ~/.ssh/id_ed25519"
echo "3. Copy public key: cat ~/.ssh/id_ed25519.pub"
echo "4. Add to GitHub: https://github.com/settings/ssh/new"
echo

echo -e "${BLUE}Option 3: Use GitHub CLI (Easiest)${NC}"
echo "1. Install: sudo apt install gh"
echo "2. Login: gh auth login"
echo "3. Follow prompts to authenticate"
echo

read -p "Which option would you like to use? (1=PAT, 2=SSH, 3=GitHub CLI, s=Skip): " -n 1 -r
echo

case $REPLY in
    1)
        echo
        print_info "Setting up Personal Access Token authentication..."
        echo
        echo "Please create your PAT at: https://github.com/settings/tokens"
        echo "Required scopes: repo"
        echo
        read -p "Enter your Personal Access Token: " -s github_token
        echo
        
        if [ -z "$github_token" ]; then
            print_error "No token provided. Skipping authentication setup."
            exit 1
        fi
        
        # Get GitHub username
        read -p "Enter your GitHub username: " github_username
        
        # Set up the remote URL with token
        github_url="https://${github_username}:${github_token}@github.com/${github_username}/emotional-avatar-demo.git"
        
        print_info "Updating remote URL with token..."
        git remote set-url origin "$github_url"
        
        print_status "Remote URL updated with Personal Access Token"
        
        # Test the connection
        print_info "Testing connection..."
        if git ls-remote origin > /dev/null 2>&1; then
            print_status "Connection successful!"
            
            # Push to GitHub
            print_info "Pushing to GitHub..."
            git branch -M main
            if git push -u origin main; then
                print_status "Successfully pushed to GitHub!"
                echo "Repository: https://github.com/${github_username}/emotional-avatar-demo"
            else
                print_error "Push failed. Please check your token and repository settings."
            fi
        else
            print_error "Connection failed. Please check your token and username."
        fi
        ;;
        
    2)
        echo
        print_info "Setting up SSH authentication..."
        
        # Check if SSH key exists
        if [ -f ~/.ssh/id_ed25519 ]; then
            print_warning "SSH key already exists at ~/.ssh/id_ed25519"
            read -p "Use existing key? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Generating new SSH key..."
                read -p "Enter your email for SSH key: " ssh_email
                ssh-keygen -t ed25519 -C "$ssh_email"
            fi
        else
            print_info "Generating SSH key..."
            read -p "Enter your email for SSH key: " ssh_email
            ssh-keygen -t ed25519 -C "$ssh_email"
        fi
        
        # Start SSH agent and add key
        print_info "Adding SSH key to agent..."
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
        
        # Display public key
        echo
        print_info "Your public SSH key (copy this to GitHub):"
        echo "================================================"
        cat ~/.ssh/id_ed25519.pub
        echo "================================================"
        echo
        echo "Add this key to GitHub:"
        echo "1. Go to: https://github.com/settings/ssh/new"
        echo "2. Paste the key above"
        echo "3. Give it a title like 'Ubuntu Development'"
        echo "4. Click 'Add SSH key'"
        echo
        
        read -p "Press Enter after adding the SSH key to GitHub..."
        
        # Update remote to use SSH
        read -p "Enter your GitHub username: " github_username
        ssh_url="git@github.com:${github_username}/emotional-avatar-demo.git"
        
        print_info "Updating remote URL to use SSH..."
        git remote set-url origin "$ssh_url"
        
        # Test SSH connection
        print_info "Testing SSH connection..."
        if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
            print_status "SSH connection successful!"
            
            # Push to GitHub
            print_info "Pushing to GitHub..."
            git branch -M main
            if git push -u origin main; then
                print_status "Successfully pushed to GitHub!"
                echo "Repository: https://github.com/${github_username}/emotional-avatar-demo"
            else
                print_error "Push failed. Please check your SSH key setup."
            fi
        else
            print_error "SSH connection failed. Please check your key setup."
        fi
        ;;
        
    3)
        echo
        print_info "Setting up GitHub CLI authentication..."
        
        # Check if GitHub CLI is installed
        if command -v gh &> /dev/null; then
            print_status "GitHub CLI is already installed"
        else
            print_info "Installing GitHub CLI..."
            
            # Install GitHub CLI
            type -p curl >/dev/null || sudo apt update && sudo apt install curl -y
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
            && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt update \
            && sudo apt install gh -y
            
            print_status "GitHub CLI installed"
        fi
        
        # Authenticate with GitHub CLI
        print_info "Authenticating with GitHub..."
        gh auth login
        
        # Get authenticated username
        github_username=$(gh api user --jq .login)
        print_status "Authenticated as: $github_username"
        
        # Create repository if it doesn't exist
        print_info "Checking if repository exists..."
        if ! gh repo view "${github_username}/emotional-avatar-demo" > /dev/null 2>&1; then
            print_info "Creating GitHub repository..."
            gh repo create emotional-avatar-demo --public --description "Real-time emotional state visualization and adaptive avatar system"
            print_status "Repository created: https://github.com/${github_username}/emotional-avatar-demo"
        else
            print_status "Repository already exists"
        fi
        
        # Update remote URL
        github_url="https://github.com/${github_username}/emotional-avatar-demo.git"
        git remote set-url origin "$github_url"
        
        # Push to GitHub
        print_info "Pushing to GitHub..."
        git branch -M main
        if git push -u origin main; then
            print_status "Successfully pushed to GitHub!"
            echo "Repository: https://github.com/${github_username}/emotional-avatar-demo"
        else
            print_error "Push failed. Please check the repository settings."
        fi
        ;;
        
    [Ss])
        print_warning "Skipping GitHub authentication setup"
        echo "You can set this up later using one of the methods above."
        ;;
        
    *)
        print_warning "Invalid option. Skipping authentication setup."
        ;;
esac

echo
echo -e "${GREEN}🎉 Authentication setup completed!${NC}"
echo "========================================="

# Show current git status
echo
print_info "Current Git configuration:"
echo "Remote URL: $(git remote get-url origin 2>/dev/null || echo 'No remote configured')"
echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'No branch')"

echo
print_info "Quick test commands:"
echo "1. Test demo: streamlit run demo_runner.py"
echo "2. Check repo status: git status"
echo "3. View on GitHub: git remote get-url origin | sed 's/\.git$//' | sed 's/.*@github\.com:/https:\/\/github\.com\//' | sed 's/https:\/\/.*@github\.com/https:\/\/github\.com/'"

echo
echo -e "${BLUE}🚀 Your emotional avatar demo is ready!${NC}"
