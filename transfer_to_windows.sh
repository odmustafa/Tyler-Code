#!/bin/bash

# Transfer SecuGen Integration Files to Windows PC
# This script helps you prepare files for transfer to Windows

echo "🚀 Preparing SecuGen Integration Files for Windows PC"
echo "=================================================="

# Create a transfer package
TRANSFER_DIR="SecuGen_Windows_Setup"
mkdir -p "$TRANSFER_DIR"

echo "📦 Copying files to transfer package..."

# Copy all necessary files
cp secugen_integration/INSTALL.bat "$TRANSFER_DIR/"
cp secugen_integration/auto_setup_windows.bat "$TRANSFER_DIR/"
cp secugen_integration/auto_setup_windows.ps1 "$TRANSFER_DIR/"
cp secugen_integration/windows_fingerprint_service.py "$TRANSFER_DIR/"
cp secugen_integration/test_integration.py "$TRANSFER_DIR/"
cp secugen_integration/verify_setup.bat "$TRANSFER_DIR/"
cp secugen_integration/requirements.txt "$TRANSFER_DIR/"
cp secugen_integration/README.md "$TRANSFER_DIR/"
cp secugen_integration/AUTOMATED_SETUP_GUIDE.md "$TRANSFER_DIR/"

# Copy SecuGen SDK files if they exist
if [ -d "Tribute_Biometric_Integration_Complete_All_Files/SecuGen_SDK_Setup" ]; then
    echo "📁 Copying SecuGen SDK files..."
    cp -r "Tribute_Biometric_Integration_Complete_All_Files/SecuGen_SDK_Setup/FDx SDK Pro for Windows v4.3.1_J1.12" "$TRANSFER_DIR/" 2>/dev/null || echo "⚠️  SDK files not found (will use simulation mode)"
fi

# Create instructions file
cat > "$TRANSFER_DIR/INSTRUCTIONS.txt" << 'EOF'
SecuGen HU20-A Setup Instructions for Windows PC
===============================================

QUICK START:
1. Copy this entire folder to your Windows PC
2. Right-click INSTALL.bat and select "Run as administrator"
3. Follow the on-screen instructions
4. Connect your SecuGen HU20-A Hamster Pro 20 to USB
5. Start the service using the desktop shortcut

FILES INCLUDED:
- INSTALL.bat - One-click installer (START HERE)
- auto_setup_windows.bat - Batch installer
- auto_setup_windows.ps1 - PowerShell installer
- windows_fingerprint_service.py - Main service
- test_integration.py - Test script
- verify_setup.bat - Verification script
- AUTOMATED_SETUP_GUIDE.md - Detailed guide

REQUIREMENTS:
- Windows 10/11
- Administrator privileges
- SecuGen HU20-A Hamster Pro 20 USB scanner
- Internet connection (for Python download if needed)

SUPPORT:
- Run verify_setup.bat to check installation
- Run test_integration.py to test functionality
- See AUTOMATED_SETUP_GUIDE.md for troubleshooting

After setup, the service will be available at:
- Local: http://localhost:5001
- Network: http://[YOUR_WINDOWS_IP]:5001
EOF

echo "✅ Transfer package created: $TRANSFER_DIR/"
echo ""
echo "📋 Next steps:"
echo "1. Copy the '$TRANSFER_DIR' folder to your Windows PC"
echo "2. On Windows PC: Right-click INSTALL.bat → 'Run as administrator'"
echo "3. Follow the automated setup process"
echo ""
echo "💡 Transfer methods:"
echo "- USB drive"
echo "- Network share"
echo "- Email (zip the folder)"
echo "- Cloud storage (Google Drive, OneDrive, etc.)"
echo ""

# Create a zip file for easy transfer
if command -v zip >/dev/null 2>&1; then
    echo "📦 Creating zip file for easy transfer..."
    zip -r "${TRANSFER_DIR}.zip" "$TRANSFER_DIR/" >/dev/null 2>&1
    echo "✅ Created: ${TRANSFER_DIR}.zip"
    echo ""
fi

echo "🎯 Ready for transfer to Windows PC!"
echo "File size: $(du -sh "$TRANSFER_DIR" | cut -f1)"

if [ -f "${TRANSFER_DIR}.zip" ]; then
    echo "Zip size: $(du -sh "${TRANSFER_DIR}.zip" | cut -f1)"
fi
