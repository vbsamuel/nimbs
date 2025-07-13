#!/bin/bash

# Fix and complete the Emotional Avatar Demo setup
# Run this from: ~/hk-projects/nimbs/

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

echo -e "${BLUE}🔧 Fixing and completing Emotional Avatar Demo setup${NC}"
echo "======================================================"

# Check if we're in the right place
if [ ! -d "emotional-avatar-demo" ]; then
    echo "❌ emotional-avatar-demo directory not found!"
    echo "Please run the initial setup script first."
    exit 1
fi

cd emotional-avatar-demo

print_info "Installing required packages for data generation..."

# Install minimal packages needed for data generation
pip install pandas numpy

print_status "Basic packages installed"

# Create sample BCI data (fixed version)
print_info "Creating sample BCI data files..."

python3 << 'EOF'
import pandas as pd
import numpy as np
import os

# Ensure directory exists
os.makedirs('data/bci_samples', exist_ok=True)

print("📊 Generating BCI sample data...")

# Sample scenarios with realistic emotional patterns
scenarios = {
    'neutral': {
        'description': 'Baseline emotional state',
        'stress': 0.3, 'engagement': 0.6, 'excitement': 0.4
    },
    'stressed': {
        'description': 'High stress work scenario', 
        'stress': 0.8, 'engagement': 0.7, 'excitement': 0.3
    },
    'relaxed': {
        'description': 'Meditation/calm state',
        'stress': 0.1, 'engagement': 0.4, 'excitement': 0.2
    },
    'excited': {
        'description': 'High energy/enthusiasm',
        'stress': 0.4, 'engagement': 0.9, 'excitement': 0.9
    }
}

for scenario_name, params in scenarios.items():
    print(f"  📝 Creating {scenario_name}_state.csv...")
    
    # Generate 2 minutes of data at 1Hz (120 samples)
    num_samples = 120
    np.random.seed(42)  # For reproducible data
    
    # Base emotional state with realistic variations
    data = {
        'timestamp': list(range(num_samples)),
        'engagement': [],
        'excitement': [], 
        'stress': [],
        'relaxation': [],
        'interest': [],
        'heart_rate': [],
        'breath_rate': []
    }
    
    for i in range(num_samples):
        # Add realistic variations over time
        time_factor = i / num_samples
        
        # Engagement (0-1)
        engagement = params['engagement'] + np.random.normal(0, 0.1) + 0.1 * np.sin(time_factor * 2 * np.pi)
        data['engagement'].append(max(0, min(1, engagement)))
        
        # Excitement (0-1) 
        excitement = params['excitement'] + np.random.normal(0, 0.15) + 0.05 * np.cos(time_factor * 3 * np.pi)
        data['excitement'].append(max(0, min(1, excitement)))
        
        # Stress (0-1)
        stress = params['stress'] + np.random.normal(0, 0.1)
        data['stress'].append(max(0, min(1, stress)))
        
        # Relaxation (inverse of stress with some independence)
        relaxation = (1 - stress) * 0.8 + np.random.normal(0, 0.05)
        data['relaxation'].append(max(0, min(1, relaxation)))
        
        # Interest (correlates with engagement)
        interest = engagement * 0.9 + np.random.normal(0, 0.08)
        data['interest'].append(max(0, min(1, interest)))
        
        # Heart rate (50-120 BPM, correlates with stress/excitement)
        base_hr = 72
        stress_effect = (stress - 0.3) * 25  # Stress increases HR
        excitement_effect = (excitement - 0.4) * 15  # Excitement increases HR
        hr_variation = np.random.normal(0, 3)
        heart_rate = base_hr + stress_effect + excitement_effect + hr_variation
        data['heart_rate'].append(max(50, min(120, heart_rate)))
        
        # Breath rate (10-25 breaths/min, correlates with stress)
        base_br = 16
        stress_br_effect = (stress - 0.3) * 8
        br_variation = np.random.normal(0, 1)
        breath_rate = base_br + stress_br_effect + br_variation
        data['breath_rate'].append(max(10, min(25, breath_rate)))
    
    # Create DataFrame and save
    df = pd.DataFrame(data)
    filename = f'data/bci_samples/{scenario_name}_state.csv'
    df.to_csv(filename, index=False)
    
    # Print sample statistics
    print(f"     📈 {scenario_name}: avg_stress={df['stress'].mean():.2f}, avg_engagement={df['engagement'].mean():.2f}")

print("✅ All BCI sample files created successfully!")
EOF

print_status "Sample BCI data created"

# Create a simple dashboard that works without additional dependencies
print_info "Creating basic dashboard..."

cat > src/ui/dashboard.py << 'EOF'
"""
Basic Streamlit Dashboard for Emotional Avatar Demo
"""

import streamlit as st
import pandas as pd
import numpy as np
from pathlib import Path
import sys

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))

try:
    from config import config
except ImportError:
    # Fallback config if import fails
    class Config:
        BCI_METRICS = ["engagement", "excitement", "stress", "relaxation", "interest", "heart_rate", "breath_rate"]
        AVATAR_EXPRESSIONS = ["neutral", "happy", "sad", "angry", "surprised", "relaxed", "stressed"]
    config = Config()

def load_bci_data(scenario="neutral"):
    """Load BCI data for a scenario"""
    try:
        data_path = Path(__file__).parent.parent.parent / "data" / "bci_samples" / f"{scenario}_state.csv"
        if data_path.exists():
            return pd.read_csv(data_path)
        else:
            st.error(f"BCI data file not found: {data_path}")
            return None
    except Exception as e:
        st.error(f"Error loading BCI data: {e}")
        return None

def main():
    """Main dashboard function"""
    
    st.set_page_config(
        page_title="🤖 Emotional Avatar Demo",
        page_icon="🤖", 
        layout="wide"
    )
    
    st.title("🤖 Emotional Avatar Demo")
    st.markdown("Real-time emotional state visualization and adaptive avatar system")
    st.markdown("---")
    
    # Sidebar controls
    st.sidebar.header("🎮 Demo Controls")
    
    # Scenario selection
    scenario = st.sidebar.selectbox(
        "Select BCI Scenario:",
        ["neutral", "stressed", "relaxed", "excited"],
        help="Choose different emotional states to visualize"
    )
    
    # Load and display data
    bci_data = load_bci_data(scenario)
    
    if bci_data is not None:
        # Main layout
        col1, col2 = st.columns([2, 1])
        
        with col1:
            st.subheader("📊 Emotional Metrics")
            
            # Display current values
            latest_data = bci_data.iloc[-1]
            
            # Create metrics display
            metric_cols = st.columns(4)
            
            with metric_cols[0]:
                st.metric(
                    "Engagement", 
                    f"{latest_data['engagement']:.2f}",
                    delta=f"{latest_data['engagement'] - 0.5:.2f}"
                )
                
            with metric_cols[1]:
                st.metric(
                    "Stress", 
                    f"{latest_data['stress']:.2f}",
                    delta=f"{latest_data['stress'] - 0.3:.2f}"
                )
                
            with metric_cols[2]:
                st.metric(
                    "Heart Rate", 
                    f"{latest_data['heart_rate']:.0f} BPM",
                    delta=f"{latest_data['heart_rate'] - 72:.0f}"
                )
                
            with metric_cols[3]:
                st.metric(
                    "Relaxation", 
                    f"{latest_data['relaxation']:.2f}",
                    delta=f"{latest_data['relaxation'] - 0.5:.2f}"
                )
            
            # Line charts for emotional metrics
            st.subheader("📈 Time Series Data")
            
            emotional_metrics = ['engagement', 'excitement', 'stress', 'relaxation', 'interest']
            chart_data = bci_data[emotional_metrics]
            st.line_chart(chart_data)
            
            # Biometric data
            st.subheader("💓 Biometric Data") 
            bio_cols = st.columns(2)
            
            with bio_cols[0]:
                st.line_chart(bci_data['heart_rate'])
                st.caption("Heart Rate (BPM)")
                
            with bio_cols[1]:
                st.line_chart(bci_data['breath_rate'])
                st.caption("Breathing Rate (breaths/min)")
        
        with col2:
            st.subheader("🎭 Avatar State")
            
            # Determine avatar expression based on emotional state
            if latest_data['stress'] > 0.6:
                avatar_state = "stressed"
                avatar_color = "🔴"
            elif latest_data['relaxation'] > 0.7:
                avatar_state = "relaxed"  
                avatar_color = "🟢"
            elif latest_data['excitement'] > 0.7:
                avatar_state = "excited"
                avatar_color = "🟡"
            else:
                avatar_state = "neutral"
                avatar_color = "🔵"
            
            st.markdown(f"## {avatar_color} {avatar_state.title()}")
            
            # Avatar placeholder
            st.markdown("""
            ```
            Current Avatar Expression:
            """ + avatar_state.upper() + """
            
            🎭 Expression Mapping:
            • High Stress    → Worried/Tense
            • High Relaxation → Calm/Peaceful  
            • High Excitement → Happy/Energetic
            • Neutral State  → Baseline/Alert
            ```
            """)
            
            # Music recommendation
            st.subheader("🎵 Music Adaptation")
            if latest_data['stress'] > 0.6:
                music_rec = "🎵 Calming classical music"
            elif latest_data['excitement'] > 0.7:
                music_rec = "🎵 Upbeat energetic music"
            elif latest_data['relaxation'] > 0.7:
                music_rec = "🎵 Ambient/nature sounds"
            else:
                music_rec = "🎵 Neutral background music"
                
            st.info(music_rec)
            
            # Controls
            st.subheader("🎮 Controls")
            
            if st.button("🔄 Refresh Data"):
                st.rerun()
                
            if st.button("📊 Show Raw Data"):
                st.dataframe(bci_data)
    
    # Footer
    st.markdown("---")
    st.markdown("### 📋 Demo Features")
    
    feature_cols = st.columns(3)
    
    with feature_cols[0]:
        st.markdown("""
        **🧠 BCI Simulation**
        - Pre-processed emotional data
        - 7 metrics @ 1Hz sampling
        - Realistic physiological patterns
        """)
        
    with feature_cols[1]:
        st.markdown("""
        **🎭 Avatar System**
        - Expression mapping
        - Real-time adaptation
        - Emotional state visualization
        """)
        
    with feature_cols[2]:
        st.markdown("""
        **🎵 Audio Adaptation**
        - Context-aware music
        - Emotional state matching
        - Dynamic soundscapes
        """)

if __name__ == "__main__":
    main()
EOF

print_status "Basic dashboard created"

# Update the main demo runner to use the new dashboard
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

# Import and run the dashboard
if __name__ == "__main__":
    from ui.dashboard import main
    main()
EOF

print_status "Demo runner updated"

# Create installation script
cat > install.sh << 'EOF'
#!/bin/bash

echo "🚀 Installing Emotional Avatar Demo..."

# Check if virtual environment is active
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "✅ Virtual environment detected: $VIRTUAL_ENV"
else
    echo "⚠️  No virtual environment detected. Consider activating one:"
    echo "   python3 -m venv venv"
    echo "   source venv/bin/activate"
fi

# Install requirements
echo "📦 Installing Python packages..."
pip install -r requirements.txt

echo "✅ Installation complete!"
echo ""
echo "🚀 To run the demo:"
echo "   streamlit run demo_runner.py"
echo ""
echo "🌐 The demo will open in your browser at:"
echo "   http://localhost:8501"
EOF

chmod +x install.sh

print_status "Installation script created"

# Create a test script to verify everything works
cat > test_setup.py << 'EOF'
#!/usr/bin/env python3
"""
Test script to verify the demo setup
"""

import sys
import os
from pathlib import Path

def test_file_structure():
    """Test that all required files and directories exist"""
    
    required_files = [
        "requirements.txt",
        "demo_runner.py", 
        "src/config.py",
        "src/ui/dashboard.py",
        ".env"
    ]
    
    required_dirs = [
        "src/data",
        "src/avatar", 
        "src/audio",
        "src/ui",
        "data/bci_samples",
        "data/models",
        "data/assets"
    ]
    
    print("🧪 Testing file structure...")
    
    all_good = True
    
    for file_path in required_files:
        if Path(file_path).exists():
            print(f"   ✅ {file_path}")
        else:
            print(f"   ❌ {file_path} - MISSING")
            all_good = False
            
    for dir_path in required_dirs:
        if Path(dir_path).exists():
            print(f"   ✅ {dir_path}/")
        else:
            print(f"   ❌ {dir_path}/ - MISSING")
            all_good = False
    
    return all_good

def test_bci_data():
    """Test that BCI data files exist and are valid"""
    
    print("\n🧪 Testing BCI data files...")
    
    scenarios = ["neutral", "stressed", "relaxed", "excited"]
    all_good = True
    
    for scenario in scenarios:
        file_path = Path(f"data/bci_samples/{scenario}_state.csv")
        if file_path.exists():
            try:
                # Try to read the file
                with open(file_path, 'r') as f:
                    lines = f.readlines()
                    if len(lines) > 1:  # Header + data
                        print(f"   ✅ {scenario}_state.csv ({len(lines)-1} data points)")
                    else:
                        print(f"   ⚠️  {scenario}_state.csv - No data")
                        all_good = False
            except Exception as e:
                print(f"   ❌ {scenario}_state.csv - Error reading: {e}")
                all_good = False
        else:
            print(f"   ❌ {scenario}_state.csv - MISSING")
            all_good = False
    
    return all_good

def test_python_imports():
    """Test that basic Python imports work"""
    
    print("\n🧪 Testing Python imports...")
    
    try:
        import pandas as pd
        print("   ✅ pandas")
    except ImportError:
        print("   ❌ pandas - Run: pip install pandas")
        return False
        
    try:
        import numpy as np
        print("   ✅ numpy")
    except ImportError:
        print("   ❌ numpy - Run: pip install numpy")
        return False
    
    return True

def main():
    """Run all tests"""
    
    print("🤖 Emotional Avatar Demo - Setup Test")
    print("=" * 40)
    
    test1 = test_file_structure()
    test2 = test_bci_data()
    test3 = test_python_imports()
    
    print("\n" + "=" * 40)
    
    if test1 and test2 and test3:
        print("🎉 ALL TESTS PASSED!")
        print("\n✅ Your demo is ready to run:")
        print("   pip install -r requirements.txt")
        print("   streamlit run demo_runner.py")
    else:
        print("❌ Some tests failed. Please fix the issues above.")
        
    return test1 and test2 and test3

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
EOF

chmod +x test_setup.py

print_status "Test script created"

# Run the test to verify everything is working
print_info "Running setup verification test..."
python3 test_setup.py

# Final git commit
print_info "Updating git repository..."
git add .
git commit -m "Complete setup: Added BCI data, dashboard, and installation scripts"

print_status "Git repository updated"

# Final instructions
echo
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo "=================================================="
echo
echo -e "${BLUE}📁 Project location:${NC} $(pwd)"
echo
echo -e "${BLUE}🚀 Next steps:${NC}"
echo "1. Install requirements:"
echo "   ./install.sh"
echo "   # OR manually: pip install -r requirements.txt"
echo
echo "2. Run the demo:"
echo "   streamlit run demo_runner.py"
echo
echo "3. Open browser:"
echo "   http://localhost:8501"
echo
echo -e "${BLUE}📊 Available BCI scenarios:${NC}"
echo "   • neutral_state.csv  - Baseline emotional state"
echo "   • stressed_state.csv - High stress work scenario"
echo "   • relaxed_state.csv  - Meditation/calm state" 
echo "   • excited_state.csv  - High energy/enthusiasm"
echo
echo -e "${BLUE}🔧 To push to GitHub:${NC}"
echo "   git remote add origin https://github.com/YOUR_USERNAME/emotional-avatar-demo.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo
