# SecuGen Fingerprint Service - PowerShell Automated Setup
# Run as Administrator for full functionality

param(
    [switch]$SkipPython,
    [switch]$SkipFirewall,
    [switch]$Quiet
)

# Set execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Colors for output
$colors = @{
    Green = "Green"
    Red = "Red"
    Yellow = "Yellow"
    Blue = "Cyan"
    White = "White"
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $colors[$Color]
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Python {
    Write-ColorOutput "🐍 Installing Python..." "Blue"
    
    # Try winget first
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        try {
            winget install Python.Python.3.11 --silent --accept-package-agreements --accept-source-agreements
            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            return $true
        }
        catch {
            Write-ColorOutput "❌ Winget installation failed" "Red"
        }
    }
    
    # Try Chocolatey
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        try {
            choco install python -y
            refreshenv
            return $true
        }
        catch {
            Write-ColorOutput "❌ Chocolatey installation failed" "Red"
        }
    }
    
    # Manual download and install
    Write-ColorOutput "📥 Downloading Python installer..." "Blue"
    $pythonUrl = "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe"
    $installerPath = "$env:TEMP\python-installer.exe"
    
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $installerPath
        Write-ColorOutput "🔧 Installing Python..." "Blue"
        Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait
        Remove-Item $installerPath -Force
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        return $true
    }
    catch {
        Write-ColorOutput "❌ Manual Python installation failed: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Test-PythonInstallation {
    try {
        $pythonVersion = python --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Python found: $pythonVersion" "Green"
            return $true
        }
    }
    catch {}
    
    Write-ColorOutput "❌ Python not found" "Red"
    return $false
}

function Install-PythonPackages {
    Write-ColorOutput "📦 Installing Python packages..." "Blue"
    
    try {
        # Upgrade pip first
        python -m pip install --upgrade pip | Out-Null
        
        # Install required packages
        python -m pip install flask flask-cors requests | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Python packages installed successfully" "Green"
            return $true
        }
    }
    catch {}
    
    Write-ColorOutput "❌ Failed to install Python packages" "Red"
    return $false
}

function Find-SecuGenSDK {
    Write-ColorOutput "🔍 Searching for SecuGen SDK..." "Blue"
    
    $sdkPaths = @(
        "sgfplib.dll",
        "bin\x64\sgfplib.dll",
        "bin\i386\sgfplib.dll",
        "C:\Program Files\SecuGen\FDx SDK Pro for Windows\bin\x64\sgfplib.dll",
        "C:\Program Files (x86)\SecuGen\FDx SDK Pro for Windows\bin\x64\sgfplib.dll",
        "..\FDx SDK Pro for Windows v4.3.1_J1.12\FDx SDK Pro for Windows v4.3.1\bin\x64\sgfplib.dll"
    )
    
    foreach ($path in $sdkPaths) {
        if (Test-Path $path) {
            Write-ColorOutput "✅ Found SDK at: $path" "Green"
            
            if ($path -ne "sgfplib.dll") {
                Copy-Item $path "sgfplib.dll" -Force
                Write-ColorOutput "✅ SDK DLL copied to current directory" "Green"
            }
            return $true
        }
    }
    
    Write-ColorOutput "⚠️  SecuGen SDK DLL not found" "Yellow"
    Write-ColorOutput "   Service will run in simulation mode only" "Yellow"
    return $false
}

function Configure-Firewall {
    if ($SkipFirewall) {
        Write-ColorOutput "⏭️  Skipping firewall configuration" "Yellow"
        return
    }
    
    Write-ColorOutput "🔥 Configuring Windows Firewall..." "Blue"
    
    try {
        # Check if rule already exists
        $existingRule = Get-NetFirewallRule -DisplayName "SecuGen Fingerprint Service" -ErrorAction SilentlyContinue
        
        if ($existingRule) {
            Write-ColorOutput "✅ Firewall rule already exists" "Green"
        } else {
            # Add firewall rule
            New-NetFirewallRule -DisplayName "SecuGen Fingerprint Service" -Direction Inbound -Protocol TCP -LocalPort 5001 -Action Allow | Out-Null
            Write-ColorOutput "✅ Firewall rule added successfully" "Green"
        }
    }
    catch {
        Write-ColorOutput "⚠️  Failed to configure firewall: $($_.Exception.Message)" "Yellow"
        Write-ColorOutput "   You may need to manually allow port 5001" "Yellow"
    }
}

function Get-NetworkInfo {
    Write-ColorOutput "🌐 Getting network information..." "Blue"
    
    try {
        $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" } | Select-Object -First 1).IPAddress
        
        if ($ipAddress) {
            Write-ColorOutput "✅ Your IP address: $ipAddress" "Green"
            Write-ColorOutput "🌍 Service will be accessible at: http://$ipAddress:5001" "Blue"
            return $ipAddress
        }
    }
    catch {}
    
    Write-ColorOutput "⚠️  Could not determine IP address" "Yellow"
    return "localhost"
}

function Test-SecuGenDevice {
    Write-ColorOutput "🔌 Testing SecuGen device connection..." "Blue"
    
    try {
        $devices = Get-PnpDevice | Where-Object { 
            $_.FriendlyName -like "*SecuGen*" -or 
            $_.FriendlyName -like "*Hamster*" -or 
            $_.FriendlyName -like "*HU20*" -or
            $_.FriendlyName -like "*Fingerprint*"
        }
        
        if ($devices) {
            Write-ColorOutput "✅ SecuGen device detected:" "Green"
            foreach ($device in $devices) {
                Write-ColorOutput "   - $($device.FriendlyName)" "Green"
            }
            return $true
        } else {
            Write-ColorOutput "⚠️  SecuGen device not detected" "Yellow"
            Write-ColorOutput "   Please ensure:" "Yellow"
            Write-ColorOutput "   - Device is connected to USB" "Yellow"
            Write-ColorOutput "   - Drivers are installed" "Yellow"
            Write-ColorOutput "   - Device appears in Device Manager" "Yellow"
            return $false
        }
    }
    catch {
        Write-ColorOutput "⚠️  Could not check device status" "Yellow"
        return $false
    }
}

function Create-StartupScript {
    param([string]$IpAddress)
    
    Write-ColorOutput "📝 Creating startup script..." "Blue"
    
    $scriptContent = @"
@echo off
title SecuGen Fingerprint Service
color 0A
echo.
echo ========================================
echo   SecuGen Fingerprint Service
echo ========================================
echo.
echo Service will be available at:
echo - Local:   http://localhost:5001
echo - Network: http://$IpAddress:5001
echo.
echo Press Ctrl+C to stop the service
echo ========================================
echo.
python windows_fingerprint_service.py
echo.
echo Service stopped. Press any key to exit...
pause >nul
"@
    
    $scriptContent | Out-File -FilePath "start_fingerprint_service.bat" -Encoding ASCII
    Write-ColorOutput "✅ Startup script created: start_fingerprint_service.bat" "Green"
}

function Create-DesktopShortcut {
    Write-ColorOutput "🖥️  Creating desktop shortcut..." "Blue"
    
    try {
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\SecuGen Fingerprint Service.lnk")
        $Shortcut.TargetPath = "$PWD\start_fingerprint_service.bat"
        $Shortcut.WorkingDirectory = $PWD
        $Shortcut.IconLocation = "shell32.dll,23"
        $Shortcut.Description = "SecuGen Fingerprint Service for Tribute System"
        $Shortcut.Save()
        
        Write-ColorOutput "✅ Desktop shortcut created" "Green"
    }
    catch {
        Write-ColorOutput "⚠️  Could not create desktop shortcut: $($_.Exception.Message)" "Yellow"
    }
}

function Test-Service {
    Write-ColorOutput "🧪 Testing service..." "Blue"
    
    try {
        # Start service in background
        $job = Start-Job -ScriptBlock { 
            Set-Location $using:PWD
            python windows_fingerprint_service.py 
        }
        
        # Wait for service to start
        Start-Sleep -Seconds 3
        
        # Test the service
        $response = Invoke-WebRequest -Uri "http://localhost:5001/api/fingerprint/status" -TimeoutSec 5 -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-ColorOutput "✅ Service test successful" "Green"
            $testResult = $true
        } else {
            Write-ColorOutput "❌ Service test failed" "Red"
            $testResult = $false
        }
        
        # Stop the test service
        Stop-Job $job -Force
        Remove-Job $job -Force
        
        return $testResult
    }
    catch {
        Write-ColorOutput "⚠️  Service test failed: $($_.Exception.Message)" "Yellow"
        return $false
    }
}

# Main execution
Clear-Host
Write-ColorOutput "========================================" "Blue"
Write-ColorOutput "SecuGen HU20-A Automated Setup Script" "Blue"
Write-ColorOutput "========================================" "Blue"
Write-Host ""

# Check administrator privileges
if (-not (Test-Administrator)) {
    Write-ColorOutput "❌ This script requires administrator privileges" "Red"
    Write-ColorOutput "Please right-click and select 'Run as Administrator'" "Yellow"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-ColorOutput "✅ Running with administrator privileges" "Green"
Write-Host ""

# Step 1: Python Installation
if (-not $SkipPython) {
    if (-not (Test-PythonInstallation)) {
        if (-not (Install-Python)) {
            Write-ColorOutput "❌ Python installation failed" "Red"
            Read-Host "Press Enter to exit"
            exit 1
        }
        
        # Test again after installation
        if (-not (Test-PythonInstallation)) {
            Write-ColorOutput "❌ Python still not available after installation" "Red"
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
} else {
    Write-ColorOutput "⏭️  Skipping Python installation check" "Yellow"
}

# Step 2: Install Python packages
if (-not (Install-PythonPackages)) {
    Write-ColorOutput "❌ Failed to install required packages" "Red"
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 3: Find SecuGen SDK
$sdkFound = Find-SecuGenSDK

# Step 4: Configure firewall
Configure-Firewall

# Step 5: Get network info
$ipAddress = Get-NetworkInfo

# Step 6: Test device
$deviceFound = Test-SecuGenDevice

# Step 7: Create startup script
Create-StartupScript -IpAddress $ipAddress

# Step 8: Create desktop shortcut
Create-DesktopShortcut

# Step 9: Test service
Write-Host ""
$serviceWorks = Test-Service

# Final summary
Write-Host ""
Write-ColorOutput "========================================" "Blue"
Write-ColorOutput "🎉 Setup Complete!" "Green"
Write-ColorOutput "========================================" "Blue"
Write-Host ""

Write-ColorOutput "Setup Summary:" "Blue"
Write-ColorOutput "✅ Python installed and configured" "Green"
Write-ColorOutput "✅ Required packages installed" "Green"
Write-ColorOutput "$(if ($sdkFound) { '✅' } else { '⚠️ ' }) SecuGen SDK $(if ($sdkFound) { 'found' } else { 'not found (simulation mode)' })" $(if ($sdkFound) { "Green" } else { "Yellow" })
Write-ColorOutput "$(if ($deviceFound) { '✅' } else { '⚠️ ' }) SecuGen device $(if ($deviceFound) { 'detected' } else { 'not detected' })" $(if ($deviceFound) { "Green" } else { "Yellow" })
Write-ColorOutput "$(if ($serviceWorks) { '✅' } else { '⚠️ ' }) Service test $(if ($serviceWorks) { 'passed' } else { 'failed' })" $(if ($serviceWorks) { "Green" } else { "Yellow" })

Write-Host ""
Write-ColorOutput "To start the fingerprint service:" "Blue"
Write-ColorOutput "• Double-click 'SecuGen Fingerprint Service' on desktop" "White"
Write-ColorOutput "• Or run: start_fingerprint_service.bat" "White"
Write-ColorOutput "• Or run: python windows_fingerprint_service.py" "White"

Write-Host ""
Write-ColorOutput "Service will be available at:" "Blue"
Write-ColorOutput "• Local:   http://localhost:5001" "White"
Write-ColorOutput "• Network: http://$ipAddress:5001" "White"

if (-not $Quiet) {
    Write-Host ""
    $startNow = Read-Host "Would you like to start the fingerprint service now? (y/N)"
    if ($startNow -eq "y" -or $startNow -eq "Y") {
        Write-Host ""
        Write-ColorOutput "🚀 Starting SecuGen Fingerprint Service..." "Green"
        Write-ColorOutput "Press Ctrl+C to stop the service" "Blue"
        Write-Host ""
        python windows_fingerprint_service.py
    }
}

Write-Host ""
Write-ColorOutput "Setup complete! 🎉" "Green"
