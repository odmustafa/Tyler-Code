# Fix Windows Long Path Issues
# Run this script as Administrator

Write-Host "=== Windows Long Path Fix Script ===" -ForegroundColor Green
Write-Host "This script will enable long path support on Windows" -ForegroundColor Yellow

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Running as Administrator" -ForegroundColor Green

# Enable long paths in registry
try {
    Write-Host "Enabling long path support in registry..." -ForegroundColor Yellow
    
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    $propertyName = "LongPathsEnabled"
    $propertyValue = 1
    
    # Check if property exists
    $currentValue = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue
    
    if ($currentValue) {
        if ($currentValue.LongPathsEnabled -eq 1) {
            Write-Host "✓ Long paths already enabled" -ForegroundColor Green
        } else {
            Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue
            Write-Host "✓ Long paths enabled successfully" -ForegroundColor Green
        }
    } else {
        New-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue -PropertyType DWORD -Force | Out-Null
        Write-Host "✓ Long paths enabled successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR: Failed to enable long paths in registry: $($_.Exception.Message)" -ForegroundColor Red
}

# Enable Git long paths
try {
    Write-Host "Configuring Git for long paths..." -ForegroundColor Yellow
    git config --global core.longpaths true
    Write-Host "✓ Git configured for long paths" -ForegroundColor Green
} catch {
    Write-Host "WARNING: Git not found or failed to configure: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test long path support
Write-Host "Testing long path support..." -ForegroundColor Yellow
$testPath = "C:\temp\very\long\path\that\exceeds\the\traditional\260\character\limit\for\windows\filesystem\operations\and\should\work\if\long\paths\are\enabled\properly"
$testFile = "$testPath\test.txt"

try {
    # Create directory structure
    New-Item -ItemType Directory -Path $testPath -Force | Out-Null
    
    # Create test file
    "Long path test successful" | Out-File -FilePath $testFile -Encoding UTF8
    
    # Verify file exists
    if (Test-Path $testFile) {
        Write-Host "✓ Long path test successful!" -ForegroundColor Green
        Remove-Item -Path "C:\temp\very" -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "⚠ Long path test failed - file not created" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Long path test failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Provide solutions for the specific file
Write-Host "`n=== Solutions for your specific file ===" -ForegroundColor Cyan
Write-Host "File: Microsoft.AspNet.FriendlyUrls.Core.1.0.2.nupkg" -ForegroundColor White

$solutions = @(
    "1. Restart your computer for registry changes to take effect",
    "2. Use robocopy: robocopy `"source_folder`" `"destination_folder`" `"Microsoft.AspNet.FriendlyUrls.Core.1.0.2.nupkg`"",
    "3. Use 7-Zip or WinRAR to extract/copy the file",
    "4. Move your project to a shorter path like C:\Tyler",
    "5. Use PowerShell Copy-Item with -Force parameter"
)

foreach ($solution in $solutions) {
    Write-Host $solution -ForegroundColor Yellow
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Restart your computer" -ForegroundColor White
Write-Host "2. Try the file operation again" -ForegroundColor White
Write-Host "3. If still having issues, try the alternative solutions above" -ForegroundColor White

Write-Host "`nScript completed!" -ForegroundColor Green
Read-Host "Press Enter to exit"
