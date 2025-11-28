# Windows Project Scanner - Anleitung

Diese PowerShell-Scripts helfen dir, deine Windows-Projektverzeichnisse zu scannen und zu analysieren.

## 📁 Verfügbare Scripts

### 1. `Quick-ProjectScan.ps1` - Schneller Überblick
**Empfohlen für:** Erste Orientierung, schnelle Checks

**Features:**
- ✓ Prüft ob Verzeichnisse existieren
- ✓ Zeigt Größe und Dateianzahl
- ✓ Erkennt Projekt-Typ (Node.js, Python, etc.)
- ✓ Zeigt Git-Status
- ✓ Listet Top-Level Verzeichnisse
- ✓ Zeigt letzte 5 geänderte Dateien

### 2. `Scan-ProjectDirectory.ps1` - Detaillierter Scan
**Empfohlen für:** Umfassende Analyse, Reports

**Features:**
- ✓ Vollständige Verzeichnisstruktur
- ✓ Datei-Typ Statistiken
- ✓ Git-Repository Analyse
- ✓ Liest wichtige Config-Dateien
- ✓ Erstellt detaillierten Report
- ✓ Öffnet Report automatisch in Notepad

## 🚀 Verwendung

### Option 1: Quick Scan (Empfohlen zum Start)

```powershell
# PowerShell als Administrator öffnen
# Navigiere zum Script-Verzeichnis
cd "C:\path\to\scripts"

# Script ausführen
.\Quick-ProjectScan.ps1
```

**Standard-Pfade werden automatisch gescannt:**
- `G:\jj doc´s\highload-agents-masterclass@fitna`
- `G:\jj doc´s`

**Custom Pfade scannen:**
```powershell
.\Quick-ProjectScan.ps1 -Paths "G:\jj doc´s", "D:\andere\projekte"
```

### Option 2: Detaillierter Scan

```powershell
# Mit Standard-Pfad (G:\jj doc´s)
.\Scan-ProjectDirectory.ps1

# Mit custom Pfad
.\Scan-ProjectDirectory.ps1 -BaseDir "D:\meine\projekte"

# Mit custom Output-File
.\Scan-ProjectDirectory.ps1 -OutputFile "C:\reports\my-scan.txt"
```

## 📋 Was die Scripts scannen

### Projekt-Erkennung

Die Scripts suchen nach folgenden Dateien:

| Datei | Projekt-Typ |
|-------|------------|
| `package.json` | Node.js / JavaScript |
| `requirements.txt` | Python |
| `pyproject.toml` | Python (modern) |
| `Cargo.toml` | Rust |
| `pom.xml` | Java (Maven) |
| `build.gradle` | Java/Kotlin (Gradle) |
| `Gemfile` | Ruby |
| `go.mod` | Go |
| `composer.json` | PHP |
| `.git/` | Git Repository |
| `README.md` | Dokumentation |
| `Dockerfile` | Docker |
| `docker-compose.yml` | Docker Compose |

### Gesammelte Informationen

1. **Verzeichnis-Info:**
   - Größe (in MB)
   - Anzahl Dateien/Verzeichnisse
   - Erstellungs- und Änderungsdatum

2. **Git-Repository:**
   - Aktueller Branch
   - Anzahl Commits
   - Letzter Commit
   - Status (geänderte Dateien)

3. **Datei-Statistiken:**
   - Gruppierung nach Dateityp
   - Anzahl pro Typ
   - Größe pro Typ

4. **Projekt-Dateien:**
   - Liest README.md
   - Liest package.json
   - Liest requirements.txt
   - Zeigt Konfigurationsdateien

## 🔧 Einrichtung

### PowerShell Execution Policy

Falls du einen Fehler wie "cannot be loaded because running scripts is disabled" bekommst:

```powershell
# PowerShell als Administrator öffnen
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Oder für diese Session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### Script-Pfad

1. **Scripts auf Windows-System kopieren:**

   **Methode A: Manuell**
   - Öffne die `.ps1` Dateien im Repository
   - Kopiere den Inhalt
   - Erstelle neue `.ps1` Dateien auf deinem Windows-System
   - Füge den Inhalt ein

   **Methode B: Git Clone**
   ```powershell
   # Wenn das Repository verfügbar ist
   git clone https://github.com/XessShare/ai-tools-knowledge-base-2025
   cd ai-tools-knowledge-base-2025\ansible\scripts
   ```

   **Methode C: Direkt Download**
   - Lade die Dateien vom Repository herunter
   - Speichere sie in einem lokalen Ordner

2. **Navigiere zum Script-Verzeichnis:**
   ```powershell
   cd "C:\Users\<dein-username>\Downloads\scripts"
   # oder wo auch immer du die Scripts gespeichert hast
   ```

## 📊 Beispiel-Output

### Quick Scan Output:

```
╔══════════════════════════════════════════════════════════════╗
║          QUICK PROJECT SCAN                                  ║
╚══════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────┐
│ Scanning: G:\jj doc´s\highload-agents-masterclass@fitna
└─────────────────────────────────────────────────────────────┘
  ✓ Path exists
  Created: 2024-01-15 14:30:22
  Modified: 2024-11-20 09:15:33
  Size: 125.45 MB
  Files: 342
  Directories: 28

  Project Files:
    ✓ package.json (Node.js/JavaScript)
    ✓ .git (Git Repository)
    ✓ README.md (Documentation)
    ✓ docker-compose.yml (Docker Compose)

  Git Info:
    Branch: main
    Commits: 127
    Last: abc1234 - Update dependencies (2 days ago)

  Top-level structure:
    📁 src (45.2 MB)
    📁 node_modules (65.8 MB)
    📁 docs (2.3 MB)
    📁 config (0.5 MB)
```

### Detaillierter Scan Output:

Erstellt eine Textdatei mit umfassenden Informationen:
- Vollständige Verzeichnisstruktur
- Alle Projekt-Dateien mit Inhalt
- Git-Historie
- Datei-Statistiken
- Directory Tree

## 🎯 Typische Anwendungsfälle

### 1. Projekt-Status prüfen

```powershell
# Schneller Check
.\Quick-ProjectScan.ps1 -Paths "G:\jj doc´s\highload-agents-masterclass@fitna"
```

### 2. Alle Projekte in einem Verzeichnis finden

```powershell
# Scan des übergeordneten Verzeichnisses
.\Scan-ProjectDirectory.ps1 -BaseDir "G:\jj doc´s"
```

### 3. Report für Dokumentation erstellen

```powershell
# Detaillierten Report erstellen
.\Scan-ProjectDirectory.ps1 -BaseDir "G:\jj doc´s\highload-agents-masterclass@fitna" -OutputFile "C:\reports\project-status.txt"
```

### 4. Mehrere Verzeichnisse vergleichen

```powershell
# Quick Scan für Vergleich
.\Quick-ProjectScan.ps1 -Paths @(
    "G:\jj doc´s\projekt-a",
    "G:\jj doc´s\projekt-b",
    "D:\backup\projekt-a"
)
```

## 🔍 Report analysieren

Nach dem Scan mit `Scan-ProjectDirectory.ps1`:

```powershell
# Report in PowerShell anzeigen
Get-Content "$env:TEMP\project-scan-report.txt"

# Report mit Paging
Get-Content "$env:TEMP\project-scan-report.txt" | more

# Nach bestimmten Begriffen suchen
Get-Content "$env:TEMP\project-scan-report.txt" | Select-String "package.json"

# Report kopieren
Copy-Item "$env:TEMP\project-scan-report.txt" -Destination "D:\reports\scan-$(Get-Date -Format 'yyyyMMdd').txt"
```

## 🐛 Troubleshooting

### "Path not found"

```powershell
# Prüfe ob der Pfad existiert
Test-Path "G:\jj doc´s"

# Liste alle Laufwerke
Get-PSDrive -PSProvider FileSystem

# Suche nach ähnlichen Verzeichnissen
Get-ChildItem "G:\" -Directory -Filter "*doc*"
```

### "Access Denied"

```powershell
# PowerShell als Administrator starten
# Rechtsklick auf PowerShell -> "Als Administrator ausführen"

# Oder Berechtigungen prüfen
Get-Acl "G:\jj doc´s"
```

### "Git not found"

```powershell
# Git installieren von: https://git-scm.com/
# Oder prüfen ob Git installiert ist:
git --version

# PATH prüfen
$env:PATH -split ';' | Select-String "git"
```

### Script wird nicht ausgeführt

```powershell
# Execution Policy prüfen
Get-ExecutionPolicy

# Temporär erlauben
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Script mit vollständigem Pfad ausführen
& "C:\full\path\to\Quick-ProjectScan.ps1"
```

## 📤 Ergebnisse an Linux-System übertragen

Wenn du die Scan-Ergebnisse an dein Linux/Ansible-System übertragen möchtest:

### Methode 1: Copy-Paste
```powershell
# Report in Zwischenablage kopieren
Get-Content "$env:TEMP\project-scan-report.txt" | Set-Clipboard

# Dann in Linux einfügen
```

### Methode 2: Netzwerk-Share
```powershell
# Auf Netzwerk-Share kopieren (falls vorhanden)
Copy-Item "$env:TEMP\project-scan-report.txt" -Destination "\\192.168.16.7\share\"
```

### Methode 3: Git
```powershell
# Report im Repository speichern
Copy-Item "$env:TEMP\project-scan-report.txt" -Destination "C:\repos\ai-tools-knowledge-base-2025\reports\"
cd "C:\repos\ai-tools-knowledge-base-2025"
git add reports/project-scan-report.txt
git commit -m "Add Windows project scan report"
git push
```

## 📚 Weiterführende Schritte

Nach dem Scan kannst du:

1. **Repository nach Linux übertragen** (falls gewünscht)
2. **Ansible Playbooks für das Projekt erstellen**
3. **CI/CD Pipeline einrichten**
4. **Dokumentation aktualisieren**
5. **Dependencies analysieren und aktualisieren**

## 🤝 Support

Bei Fragen oder Problemen:
- Prüfe die Troubleshooting-Section
- Führe Quick-Scan mit `-Verbose` aus
- Checke PowerShell Version: `$PSVersionTable.PSVersion`

**Viel Erfolg! 🚀**
