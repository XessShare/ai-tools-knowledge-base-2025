@echo off
REM ===================================================================
REM Quick Project Scan Launcher
REM Doppelklick auf diese Datei zum Ausführen
REM ===================================================================

echo.
echo ===================================================================
echo   QUICK PROJECT SCANNER - LAUNCHER
echo ===================================================================
echo.

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

echo Script Directory: %SCRIPT_DIR%
echo.

REM Check if PowerShell script exists
if not exist "%SCRIPT_DIR%Quick-ProjectScan.ps1" (
    echo ERROR: Quick-ProjectScan.ps1 not found!
    echo Expected location: %SCRIPT_DIR%Quick-ProjectScan.ps1
    echo.
    echo Please ensure the PowerShell script is in the same directory as this batch file.
    pause
    exit /b 1
)

echo Starting Quick Project Scan...
echo.

REM Run PowerShell script with execution policy bypass
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPT_DIR%Quick-ProjectScan.ps1"

echo.
echo ===================================================================
echo   SCAN COMPLETE
echo ===================================================================
echo.
pause
