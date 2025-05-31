@echo off
echo =================================
echo Project Path Shortening Script
echo =================================
echo.
echo This script will rename long folder names to shorter ones
echo to help avoid Windows path length limitations.
echo.
echo Current long folder names:
echo - Tribute_Biometric_Integration_Complete_All_Files
echo - SecuGen_Windows_Setup
echo.
echo Will be renamed to:
echo - TBI_Files
echo - SecuGen_Setup
echo.
set /p confirm="Continue? (y/n): "
if /i not "%confirm%"=="y" goto :end

echo.
echo Renaming folders...

:: Rename the long folder names
if exist "Tribute_Biometric_Integration_Complete_All_Files" (
    if not exist "TBI_Files" (
        ren "Tribute_Biometric_Integration_Complete_All_Files" "TBI_Files"
        echo SUCCESS: Renamed Tribute_Biometric_Integration_Complete_All_Files to TBI_Files
    ) else (
        echo WARNING: TBI_Files already exists, skipping rename
    )
) else (
    echo INFO: Tribute_Biometric_Integration_Complete_All_Files not found
)

if exist "SecuGen_Windows_Setup" (
    if not exist "SecuGen_Setup" (
        ren "SecuGen_Windows_Setup" "SecuGen_Setup"
        echo SUCCESS: Renamed SecuGen_Windows_Setup to SecuGen_Setup
    ) else (
        echo WARNING: SecuGen_Setup already exists, skipping rename
    )
) else (
    echo INFO: SecuGen_Windows_Setup not found
)

echo.
echo Creating symbolic links for node_modules to reduce depth...
if exist "node_modules" (
    if not exist "nm" (
        mklink /J nm node_modules
        echo SUCCESS: Created junction link 'nm' for node_modules
    ) else (
        echo INFO: Junction link 'nm' already exists
    )
)

echo.
echo =================================
echo Folder renaming completed!
echo =================================
echo.
echo You may need to update any scripts or references
echo that use the old folder names.
echo.

:end
pause
