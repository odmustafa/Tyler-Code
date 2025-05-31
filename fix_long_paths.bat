@echo off
echo =================================
echo Windows Long Path Fix
echo =================================
echo.
echo This will enable long path support on Windows
echo You need to run this as Administrator
echo.
pause

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator...
) else (
    echo ERROR: This script must be run as Administrator!
    echo Right-click this file and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo Enabling long path support...

:: Enable long paths in registry
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f

if %errorLevel% == 0 (
    echo SUCCESS: Long paths enabled in registry
) else (
    echo ERROR: Failed to enable long paths
)

:: Configure Git for long paths
echo.
echo Configuring Git for long paths...
git config --global core.longpaths true

echo.
echo =================================
echo IMPORTANT: You must restart your computer
echo for the changes to take effect!
echo =================================
echo.
echo Alternative solutions if restart doesn't work:
echo 1. Use robocopy for file operations
echo 2. Use 7-Zip or WinRAR
echo 3. Move project to shorter path (like C:\Tyler)
echo 4. Use PowerShell with -Force parameter
echo.
pause
