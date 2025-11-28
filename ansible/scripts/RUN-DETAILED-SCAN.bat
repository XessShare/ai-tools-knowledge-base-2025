@echo off
REM ===================================================================
REM Detailed Project Scan Launcher
REM Doppelklick auf diese Datei zum Ausführen
REM ===================================================================

echo.
echo ===================================================================
echo   DETAILED PROJECT SCANNER - LAUNCHER
echo ===================================================================
echo.

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

echo Script Directory: %SCRIPT_DIR%
echo.

REM Check if PowerShell script exists
if not exist "%SCRIPT_DIR%Scan-ProjectDirectory.ps1" (
    echo ERROR: Scan-ProjectDirectory.ps1 not found!
    echo Expected location: %SCRIPT_DIR%Scan-ProjectDirectory.ps1
    echo.
    echo Please ensure the PowerShell script is in the same directory as this batch file.
    pause
    exit /b 1
)

echo This will create a detailed report of your project directories.
echo.
echo Default paths to scan:
echo   - G:\jj doc's
echo   - G:\jj doc's\highload-agents-masterclass@fitna
echo.
echo Press any key to start the scan, or CTRL+C to cancel...
pause >nul

echo.
echo Starting Detailed Project Scan...
echo This may take a few minutes depending on the size of your directories...
echo.

REM Run PowerShell script with execution policy bypass
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPT_DIR%Scan-ProjectDirectory.ps1"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================================================
    echo   SCAN COMPLETE - Report has been opened in Notepad
    echo ===================================================================
    echo.
    echo The report has been saved to: %TEMP%\project-scan-report.txt
    echo.
) else (
    echo.
    echo ===================================================================
    echo   SCAN FAILED - Please check the errors above
    echo ===================================================================
    echo.
)

pause
