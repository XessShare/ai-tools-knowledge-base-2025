# ===================================================================
# Quick Project Scanner
# Schneller Überblick über Projekt-Verzeichnisse
# ===================================================================

param(
    [string[]]$Paths = @(
        "G:\jj doc´s\highload-agents-masterclass@fitna",
        "G:\jj doc´s"
    )
)

$ErrorActionPreference = 'Continue'

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          QUICK PROJECT SCAN                                  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

foreach ($path in $Paths) {
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Blue
    Write-Host "│ Scanning: $path" -ForegroundColor Yellow
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor Blue

    if (-not (Test-Path $path)) {
        Write-Host "  ✗ Path not found!" -ForegroundColor Red
        Write-Host ""
        continue
    }

    Write-Host "  ✓ Path exists" -ForegroundColor Green

    # Basic info
    $item = Get-Item $path
    Write-Host "  Created: $($item.CreationTime)" -ForegroundColor Gray
    Write-Host "  Modified: $($item.LastWriteTime)" -ForegroundColor Gray

    # Size calculation
    try {
        $size = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        Write-Host "  Size: $sizeMB MB" -ForegroundColor Cyan
    } catch {
        Write-Host "  Size: Unable to calculate" -ForegroundColor Yellow
    }

    # File count
    try {
        $fileCount = (Get-ChildItem $path -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
        $dirCount = (Get-ChildItem $path -Directory -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
        Write-Host "  Files: $fileCount" -ForegroundColor Cyan
        Write-Host "  Directories: $dirCount" -ForegroundColor Cyan
    } catch {
        Write-Host "  Unable to count files/directories" -ForegroundColor Yellow
    }

    # Check for project indicators
    Write-Host "`n  Project Files:" -ForegroundColor Magenta

    $indicators = @{
        "package.json" = "Node.js/JavaScript"
        "requirements.txt" = "Python"
        "pyproject.toml" = "Python (modern)"
        "Cargo.toml" = "Rust"
        "pom.xml" = "Java (Maven)"
        "build.gradle" = "Java/Kotlin (Gradle)"
        "Gemfile" = "Ruby"
        "go.mod" = "Go"
        "composer.json" = "PHP"
        ".git" = "Git Repository"
        "README.md" = "Documentation"
        "Dockerfile" = "Docker"
        "docker-compose.yml" = "Docker Compose"
        ".env" = "Environment Config"
        "Makefile" = "Make Build System"
    }

    $foundIndicators = @{}

    foreach ($file in $indicators.Keys) {
        $filePath = Join-Path $path $file
        if (Test-Path $filePath) {
            Write-Host "    ✓ $file" -ForegroundColor Green -NoNewline
            Write-Host " ($($indicators[$file]))" -ForegroundColor Gray
            $foundIndicators[$file] = $indicators[$file]
        }
    }

    if ($foundIndicators.Count -eq 0) {
        Write-Host "    No standard project files found" -ForegroundColor Yellow
    }

    # Git info if available
    if (Test-Path (Join-Path $path ".git")) {
        Write-Host "`n  Git Info:" -ForegroundColor Magenta
        Push-Location $path
        try {
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            $commits = git rev-list --count HEAD 2>$null
            $lastCommit = git log -1 --format="%h - %s (%ar)" 2>$null

            Write-Host "    Branch: $branch" -ForegroundColor Cyan
            Write-Host "    Commits: $commits" -ForegroundColor Cyan
            Write-Host "    Last: $lastCommit" -ForegroundColor Cyan
        } catch {
            Write-Host "    Git info unavailable" -ForegroundColor Yellow
        }
        Pop-Location
    }

    # Top-level directory structure
    Write-Host "`n  Top-level structure:" -ForegroundColor Magenta
    try {
        Get-ChildItem $path -Directory -ErrorAction Stop | ForEach-Object {
            $subSize = (Get-ChildItem $_.FullName -File -Recurse -ErrorAction SilentlyContinue |
                       Measure-Object -Property Length -Sum).Sum
            $subSizeMB = [math]::Round($subSize / 1MB, 2)
            Write-Host "    📁 $($_.Name)" -ForegroundColor Cyan -NoNewline
            Write-Host " ($subSizeMB MB)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "    Unable to list directories" -ForegroundColor Yellow
    }

    # Important files
    Write-Host "`n  Recent files (last 5):" -ForegroundColor Magenta
    try {
        Get-ChildItem $path -File -Recurse -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 5 |
            ForEach-Object {
                $relPath = $_.FullName.Replace($path, "").TrimStart('\')
                $age = (Get-Date) - $_.LastWriteTime
                $ageStr = if ($age.Days -gt 0) { "$($age.Days)d ago" }
                         elseif ($age.Hours -gt 0) { "$($age.Hours)h ago" }
                         else { "$($age.Minutes)m ago" }

                Write-Host "    📄 $relPath" -ForegroundColor Gray -NoNewline
                Write-Host " ($ageStr)" -ForegroundColor DarkGray
            }
    } catch {
        Write-Host "    Unable to list files" -ForegroundColor Yellow
    }

    Write-Host ""
}

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                  SCAN COMPLETE                               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "For detailed scan, run:" -ForegroundColor Yellow
Write-Host "  .\Scan-ProjectDirectory.ps1" -ForegroundColor White
Write-Host ""
