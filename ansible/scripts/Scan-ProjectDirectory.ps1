# ===================================================================
# Project Directory Scanner
# Scannt Windows-Verzeichnisse und erstellt detaillierte Reports
# ===================================================================

param(
    [string]$BaseDir = "G:\jj doc´s",
    [string]$OutputFile = "$env:TEMP\project-scan-report.txt"
)

$ErrorActionPreference = 'Continue'

# ===================================================================
# FUNCTIONS
# ===================================================================

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Get-DirectorySize {
    param([string]$Path)
    try {
        $size = (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        return [math]::Round($size / 1MB, 2)
    } catch {
        return 0
    }
}

function Get-FilesByType {
    param([string]$Path)
    try {
        Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue |
            Group-Object Extension |
            Sort-Object Count -Descending |
            Select-Object @{N='Type';E={$_.Name}}, Count, @{N='Size(MB)';E={
                [math]::Round(($_.Group | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
            }} |
            Format-Table -AutoSize
    } catch {
        Write-Output "No files found or access denied"
    }
}

# ===================================================================
# MAIN SCRIPT
# ===================================================================

Write-ColorOutput Cyan @"

╔══════════════════════════════════════════════════════════════╗
║          PROJECT DIRECTORY SCANNER                           ║
╚══════════════════════════════════════════════════════════════╝

"@

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @()

$report += "=" * 80
$report += "PROJECT DIRECTORY SCAN REPORT"
$report += "=" * 80
$report += "Scan Time: $timestamp"
$report += "Base Directory: $BaseDir"
$report += ""

# ===================================================================
# Check if base directory exists
# ===================================================================

if (-not (Test-Path $BaseDir)) {
    Write-ColorOutput Red "ERROR: Directory not found: $BaseDir"
    exit 1
}

Write-ColorOutput Green "✓ Base directory found: $BaseDir"
$report += "Status: Directory found"
$report += ""

# ===================================================================
# Scan main directory
# ===================================================================

Write-ColorOutput Yellow "`n[1/6] Scanning directory structure..."

$report += "-" * 80
$report += "DIRECTORY STRUCTURE"
$report += "-" * 80

try {
    $dirs = Get-ChildItem $BaseDir -Directory -ErrorAction Stop
    $report += "`nSubdirectories found: $($dirs.Count)"
    $report += ""

    foreach ($dir in $dirs) {
        $size = Get-DirectorySize $dir.FullName
        $fileCount = (Get-ChildItem $dir.FullName -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count

        $report += "📁 $($dir.Name)"
        $report += "   Path: $($dir.FullName)"
        $report += "   Size: $size MB"
        $report += "   Files: $fileCount"
        $report += "   Created: $($dir.CreationTime)"
        $report += "   Modified: $($dir.LastWriteTime)"
        $report += ""

        Write-ColorOutput Cyan "  📁 $($dir.Name) - $size MB - $fileCount files"
    }
} catch {
    $report += "Error scanning directory: $_"
    Write-ColorOutput Red "Error: $_"
}

# ===================================================================
# Scan highload-agents-masterclass@fitna specifically
# ===================================================================

$projectDir = Join-Path $BaseDir "highload-agents-masterclass@fitna"
$report += ""
$report += "-" * 80
$report += "HIGHLOAD-AGENTS-MASTERCLASS@FITNA PROJECT ANALYSIS"
$report += "-" * 80

if (Test-Path $projectDir) {
    Write-ColorOutput Yellow "`n[2/6] Analyzing highload-agents-masterclass@fitna..."

    $report += "Project Directory: $projectDir"
    $report += "Status: FOUND"
    $report += ""

    # Check for common project files
    $projectFiles = @(
        "package.json",
        "requirements.txt",
        "pyproject.toml",
        "Cargo.toml",
        "pom.xml",
        "build.gradle",
        "Makefile",
        "Dockerfile",
        "docker-compose.yml",
        ".git",
        "README.md",
        "README.txt",
        ".gitignore"
    )

    $report += "Project Files Found:"
    foreach ($file in $projectFiles) {
        $filePath = Join-Path $projectDir $file
        if (Test-Path $filePath) {
            $report += "  ✓ $file"
            Write-ColorOutput Green "  ✓ $file"

            # Read important files
            if ($file -eq "README.md" -or $file -eq "README.txt") {
                $report += "`n--- README Content ---"
                $report += Get-Content $filePath -ErrorAction SilentlyContinue
                $report += "--- End README ---`n"
            }

            if ($file -eq "package.json") {
                $report += "`n--- package.json Content ---"
                $report += Get-Content $filePath -ErrorAction SilentlyContinue
                $report += "--- End package.json ---`n"
            }

            if ($file -eq "requirements.txt") {
                $report += "`n--- requirements.txt Content ---"
                $report += Get-Content $filePath -ErrorAction SilentlyContinue
                $report += "--- End requirements.txt ---`n"
            }
        } else {
            $report += "  ✗ $file (not found)"
        }
    }

    $report += ""

    # Git status
    if (Test-Path (Join-Path $projectDir ".git")) {
        Write-ColorOutput Yellow "`n[3/6] Checking Git status..."
        $report += "-" * 40
        $report += "GIT REPOSITORY STATUS"
        $report += "-" * 40

        Push-Location $projectDir
        try {
            $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
            $gitStatus = git status --short 2>$null
            $gitLog = git log --oneline -10 2>$null

            $report += "Current Branch: $gitBranch"
            $report += "`nGit Status:"
            $report += $gitStatus
            $report += "`nRecent Commits:"
            $report += $gitLog
            $report += ""

            Write-ColorOutput Cyan "  Branch: $gitBranch"
        } catch {
            $report += "Git not available or not a git repository"
        }
        Pop-Location
    }

    # File statistics
    Write-ColorOutput Yellow "`n[4/6] Analyzing file types..."
    $report += "-" * 40
    $report += "FILE TYPE STATISTICS"
    $report += "-" * 40

    $fileStats = Get-FilesByType $projectDir
    $report += $fileStats | Out-String

    # Directory tree
    Write-ColorOutput Yellow "`n[5/6] Creating directory tree..."
    $report += "-" * 40
    $report += "DIRECTORY TREE"
    $report += "-" * 40

    try {
        $tree = tree /F /A $projectDir 2>$null
        if ($tree) {
            $report += $tree | Out-String
        } else {
            # Alternative tree using PowerShell
            Get-ChildItem $projectDir -Recurse -Depth 3 -ErrorAction SilentlyContinue |
                ForEach-Object {
                    $indent = "  " * ($_.FullName.Split('\').Count - $projectDir.Split('\').Count - 1)
                    if ($_.PSIsContainer) {
                        $report += "$indent📁 $($_.Name)"
                    } else {
                        $report += "$indent📄 $($_.Name) ($([math]::Round($_.Length/1KB, 2)) KB)"
                    }
                }
        }
    } catch {
        $report += "Error creating tree: $_"
    }

} else {
    Write-ColorOutput Red "`n✗ Project directory not found: $projectDir"
    $report += "Status: NOT FOUND"
    $report += ""

    # Search for similar directories
    $report += "Searching for similar directories..."
    Get-ChildItem $BaseDir -Directory -Filter "*highload*" -Recurse -Depth 2 -ErrorAction SilentlyContinue |
        ForEach-Object {
            $report += "  Found: $($_.FullName)"
            Write-ColorOutput Yellow "  Found similar: $($_.Name)"
        }
}

# ===================================================================
# Scan all subdirectories
# ===================================================================

Write-ColorOutput Yellow "`n[6/6] Scanning all subdirectories for project files..."

$report += ""
$report += "-" * 80
$report += "ALL PROJECT FILES IN BASE DIRECTORY"
$report += "-" * 80

$allProjectFiles = Get-ChildItem $BaseDir -Recurse -Depth 3 -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -match '\.(json|md|txt|py|js|ts|yml|yaml|toml|xml|gradle|sh|ps1|dockerfile)$' -or
        $_.Name -eq 'Makefile' -or
        $_.Name -eq '.gitignore'
    }

$report += "`nImportant files found: $($allProjectFiles.Count)"
$report += ""

$allProjectFiles | ForEach-Object {
    $relativePath = $_.FullName.Replace($BaseDir, "").TrimStart('\')
    $report += "  $relativePath"
}

# ===================================================================
# Save report
# ===================================================================

$report += ""
$report += "=" * 80
$report += "END OF REPORT - $timestamp"
$report += "=" * 80

$report | Out-File -FilePath $OutputFile -Encoding UTF8

Write-ColorOutput Green "`n✓ Report saved to: $OutputFile"
Write-ColorOutput Cyan "`nOpening report..."

# Open report in default text editor
notepad $OutputFile

Write-ColorOutput Green @"

╔══════════════════════════════════════════════════════════════╗
║                  SCAN COMPLETE                               ║
╚══════════════════════════════════════════════════════════════╝

"@

Write-Output "Report location: $OutputFile"
Write-Output ""
Write-Output "You can also view the report with:"
Write-Output "  Get-Content '$OutputFile'"
Write-Output "  or"
Write-Output "  cat '$OutputFile'"
