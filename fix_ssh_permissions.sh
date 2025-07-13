#!/bin/bash

# Fix SSH Key Permissions for GitHub
# The SSH key needs to be added to your GitHub account, not as a deploy key

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

echo -e "${BLUE}🔐 Fixing SSH Key Permissions for GitHub${NC}"
echo "=============================================="

print_error "The SSH key was added as a 'deploy key' which has limited permissions."
print_info "We need to add it to your GitHub account SSH keys instead."

echo
echo -e "${YELLOW}STEP 1: Remove the deploy key (if you added it to repository settings)${NC}"
echo "1. Go to: https://github.com/vbsamuel/nimbs/settings/keys"
echo "2. If you see your SSH key there, delete it"
echo

echo -e "${YELLOW}STEP 2: Add SSH key to your GitHub account${NC}"
echo "1. Go to: https://github.com/settings/keys"
echo "2. Click 'New SSH key'"
echo "3. Title: 'Ubuntu Development'"
echo "4. Key type: 'Authentication Key'"
echo "5. Paste this key:"
echo

print_info "Your SSH public key:"
echo "================================================"
if [ -f ~/.ssh/id_ed25519.pub ]; then
    cat ~/.ssh/id_ed25519.pub
else
    print_error "SSH public key not found at ~/.ssh/id_ed25519.pub"
    print_info "Let's generate a new one..."
    
    read -p "Enter your email for SSH key: " ssh_email
    ssh-keygen -t ed25519 -C "$ssh_email"
    
    # Add to SSH agent
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    
    echo
    print_info "New SSH public key:"
    echo "================================================"
    cat ~/.ssh/id_ed25519.pub
fi
echo "================================================"

echo
read -p "Press Enter after adding the SSH key to your GitHub account settings..."

# Test SSH connection
print_info "Testing SSH connection..."
ssh_test=$(ssh -T git@github.com 2>&1 || true)

if echo "$ssh_test" | grep -q "successfully authenticated"; then
    print_status "SSH authentication successful!"
    
    # Extract username from SSH test
    github_username=$(echo "$ssh_test" | grep -o "Hi [^!]*" | cut -d' ' -f2)
    print_status "Authenticated as: $github_username"
    
    # Now try to push
    print_info "Attempting to push to GitHub..."
    
    if git push -u origin main; then
        print_status "Successfully pushed to GitHub!"
        echo
        echo -e "${GREEN}🎉 Your emotional avatar demo is now on GitHub!${NC}"
        echo "Repository: https://github.com/vbsamuel/nimbs"
        
    else
        print_warning "Push failed. Let's try a different approach..."
        
        # Check if remote repo exists and has content
        print_info "Checking remote repository status..."
        
        if git ls-remote origin main >/dev/null 2>&1; then
            print_info "Remote main branch exists. Trying to merge..."
            
            # Fetch and merge
            git fetch origin
            git branch --set-upstream-to=origin/main main
            
            if git merge origin/main --allow-unrelated-histories; then
                print_info "Merged successfully. Pushing..."
                git push origin main
                print_status "Push successful after merge!"
            else
                print_error "Merge conflicts detected. Manual resolution needed."
                echo
                echo "To resolve manually:"
                echo "1. Fix merge conflicts in affected files"
                echo "2. git add ."
                echo "3. git commit -m 'Merge conflicts resolved'"
                echo "4. git push origin main"
            fi
        else
            print_info "Remote main branch doesn't exist. Creating new branch..."
            git push --set-upstream origin main
            print_status "New main branch created and pushed!"
        fi
    fi
    
elif echo "$ssh_test" | grep -q "Permission denied"; then
    print_error "SSH key still not working. Let's troubleshoot..."
    echo
    echo "Possible issues:"
    echo "1. SSH key not added to GitHub account (vs deploy keys)"
    echo "2. SSH agent not running"
    echo "3. Wrong SSH key being used"
    echo
    
    print_info "Let's check SSH agent and keys..."
    
    # Check SSH agent
    if ssh-add -l >/dev/null 2>&1; then
        print_status "SSH agent is running"
        print_info "Loaded keys:"
        ssh-add -l
    else
        print_warning "SSH agent not running or no keys loaded"
        print_info "Starting SSH agent and adding key..."
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
    fi
    
    echo
    print_info "Try the SSH test again:"
    echo "ssh -T git@github.com"
    echo
    print_info "If it still fails, double-check:"
    echo "1. SSH key is in: https://github.com/settings/keys (NOT repository deploy keys)"
    echo "2. Key type is 'Authentication Key'"
    echo "3. The key matches what's shown above"
    
else
    print_warning "Unexpected SSH response: $ssh_test"
    print_info "Let's try manual verification..."
fi

echo
echo -e "${BLUE}🔧 Alternative: Use HTTPS with Personal Access Token${NC}"
echo "If SSH continues to have issues, we can use HTTPS:"
echo
echo "1. Go to: https://github.com/settings/tokens"
echo "2. Generate new token with 'repo' scope"
echo "3. Run: git remote set-url origin https://github.com/vbsamuel/nimbs.git"
echo "4. When pushing, use your username and token as password"

echo
echo -e "${BLUE}🚀 Once authentication works:${NC}"
echo "Test your demo: streamlit run demo_runner.py"
echo "View repository: https://github.com/vbsamuel/nimbs"

# Show current status
echo
print_info "Current Git status:"
echo "Remote: $(git remote get-url origin)"
echo "Branch: $(git branch --show-current)"
echo "Commits ahead: $(git rev-list --count origin/main..HEAD 2>/dev/null || echo "unknown")"
