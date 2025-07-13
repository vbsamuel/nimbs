#!/bin/bash

# Final fix to complete the GitHub push
# Handle uncommitted changes and resolve conflicts

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

echo -e "${BLUE}🔧 Final GitHub Push Fix${NC}"
echo "========================="

print_info "GitHub CLI authentication is working! Now let's handle the repository sync."

# Step 1: Commit all current changes
print_info "Step 1: Committing all current changes..."

git add .

if git diff --staged --quiet; then
    print_info "No changes to commit"
else
    print_info "Committing local changes..."
    git commit -m "Complete Emotional Avatar Demo setup

- Enhanced requirements.txt with all dependencies
- Updated config.py with full configuration
- Improved dashboard.py with complete functionality
- Added new audio and avatar modules
- Added emotion processing and visualization components
- Ready for production deployment"

    print_status "All changes committed"
fi

# Step 2: Check what's on the remote
print_info "Step 2: Checking remote repository content..."

git fetch origin

# Show the divergence
print_info "Checking repository status:"
echo "Local commits ahead: $(git rev-list --count origin/main..HEAD 2>/dev/null || echo '0')"
echo "Remote commits ahead: $(git rev-list --count HEAD..origin/main 2>/dev/null || echo '0')"

# Step 3: Handle the conflict resolution
print_info "Step 3: Resolving repository divergence..."

echo
print_warning "Repository histories have diverged. Choose resolution method:"
echo "1. Merge remote changes (keeps both histories)"
echo "2. Rebase on remote (clean linear history)" 
echo "3. Force push (overwrites remote - use with caution)"
echo "4. Start fresh (backup current, pull clean, reapply changes)"

read -p "Choose option (1-4): " -n 1 -r
echo

case $REPLY in
    1)
        print_info "Option 1: Merging remote changes..."
        
        if git pull origin main --allow-unrelated-histories; then
            print_status "Merge successful!"
            
            print_info "Pushing merged result..."
            if git push origin main; then
                print_status "Push successful!"
            else
                print_error "Push failed after merge"
            fi
        else
            print_error "Merge failed - conflicts need manual resolution"
            print_info "Fix conflicts and run: git add . && git commit && git push"
        fi
        ;;
        
    2)
        print_info "Option 2: Rebasing on remote..."
        
        if git rebase origin/main; then
            print_status "Rebase successful!"
            
            print_info "Pushing rebased history..."
            if git push origin main; then
                print_status "Push successful!"
            else
                print_error "Push failed after rebase"
            fi
        else
            print_error "Rebase failed - conflicts need manual resolution"
            print_info "Fix conflicts and run: git add . && git rebase --continue && git push"
        fi
        ;;
        
    3)
        print_warning "Option 3: Force pushing (will overwrite remote)..."
        read -p "This will permanently overwrite remote content. Continue? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Force pushing..."
            if git push --force origin main; then
                print_status "Force push successful!"
            else
                print_error "Force push failed"
            fi
        else
            print_info "Force push cancelled"
        fi
        ;;
        
    4)
        print_info "Option 4: Starting fresh..."
        
        # Backup current work
        backup_dir="../emotional-avatar-backup-$(date +%Y%m%d_%H%M%S)"
        print_info "Creating backup at: $backup_dir"
        cp -r . "$backup_dir"
        print_status "Backup created"
        
        # Reset to remote state
        print_info "Resetting to remote state..."
        git reset --hard origin/main
        
        # Reapply our demo files
        print_info "Reapplying demo files from backup..."
        
        # Copy key demo files back
        cp -r "$backup_dir/src" .
        cp -r "$backup_dir/data" .
        cp "$backup_dir/demo_runner.py" .
        cp "$backup_dir/requirements.txt" .
        cp "$backup_dir/README.md" .
        
        # Add and commit
        git add .
        git commit -m "Add Emotional Avatar Demo to NIMBS repository

Complete functional demo with:
- Real-time emotional visualization
- BCI data simulation  
- Interactive Streamlit dashboard
- Avatar state mapping
- Professional documentation"

        # Push
        if git push origin main; then
            print_status "Fresh start successful!"
        else
            print_error "Push failed even with fresh start"
        fi
        ;;
        
    *)
        print_warning "Invalid option selected"
        exit 1
        ;;
esac

# Final verification
echo
print_info "Final verification..."

if git status | grep -q "Your branch is up to date"; then
    print_status "Repository is in sync!"
    
    echo
    echo -e "${GREEN}🎉 SUCCESS! Your Emotional Avatar Demo is now on GitHub!${NC}"
    echo "================================================================"
    echo
    echo -e "${BLUE}🔗 Repository links:${NC}"
    echo "Main repository: https://github.com/vbsamuel/nimbs"
    echo "Demo folder: https://github.com/vbsamuel/nimbs/tree/main/emotional-avatar-demo"
    echo
    echo -e "${BLUE}🚀 Test your demo:${NC}"
    echo "streamlit run demo_runner.py"
    echo "→ Opens at: http://localhost:8501"
    echo
    echo -e "${BLUE}👥 For others to clone:${NC}"
    echo "git clone https://github.com/vbsamuel/nimbs.git"
    echo "cd nimbs/emotional-avatar-demo"
    echo "pip install -r requirements.txt"
    echo "streamlit run demo_runner.py"
    
    # Quick demo test
    echo
    print_info "Quick demo functionality test..."
    if python3 -c "import sys; sys.path.append('src'); from ui.dashboard import main; print('✅ Dashboard import successful')"; then
        print_status "Demo is ready to run!"
    else
        print_warning "Demo may need dependency installation: pip install -r requirements.txt"
    fi
    
else
    print_warning "Repository sync incomplete. Current status:"
    git status --short
    
    print_info "Manual steps to complete:"
    echo "1. Check git status"
    echo "2. Resolve any remaining issues"
    echo "3. git push origin main"
fi

echo
echo -e "${BLUE}📊 Demo Features Available:${NC}"
echo "• 7 real-time emotional metrics"
echo "• 4 BCI scenarios (neutral, stressed, relaxed, excited)"
echo "• Interactive Streamlit dashboard"
echo "• Avatar state mapping"
echo "• Music recommendations"
echo "• Professional GitHub repository"
echo "• Ready for development and collaboration"

print_status "Setup completed! 🤖"
