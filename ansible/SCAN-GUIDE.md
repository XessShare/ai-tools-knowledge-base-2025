# Proxmox Server Scan Guide

Umfassende Anleitung zum Scannen und Analysieren deiner Proxmox Server.

## Übersicht

Es gibt zwei Methoden zum Scannen deiner Proxmox Server:

1. **Ansible Playbook** (empfohlen) - Automatisiert, strukturiert, für mehrere Server
2. **Standalone Bash Script** - Direktes Ausführen auf einem einzelnen Server

## Methode 1: Ansible Playbook (Empfohlen)

### Voraussetzungen

```bash
# Ansible Collections installieren
cd ansible
ansible-galaxy collection install -r requirements.yml

# SSH-Zugriff testen
ansible proxmox -m ping
```

### Server Scan ausführen

```bash
cd ansible

# Alle Proxmox Server scannen
ansible-playbook playbooks/server-scan.yml

# Nur einen bestimmten Server scannen
ansible-playbook playbooks/server-scan.yml --limit pve-thinkpad

# Mit erhöhter Verbosity (für Debugging)
ansible-playbook playbooks/server-scan.yml -vv
```

### Was wird gescannt?

Das Ansible Playbook sammelt folgende Informationen:

#### System Information
- Hostname und Kernel-Version
- CPU-Informationen (lscpu)
- Arbeitsspeicher (RAM)
- Festplattennutzung
- OS Release Information
- System Uptime

#### Proxmox Spezifisch
- Proxmox Version (pveversion)
- Cluster Status und Nodes
- Proxmox Service Status (pve-cluster, pvedaemon, pveproxy, etc.)

#### Storage
- Proxmox Storage Status (pvesm status)
- ZFS Pools und Datasets (falls vorhanden)
- LVM Physical Volumes, Volume Groups, Logical Volumes
- Block Device Liste

#### Virtual Machines & Container
- Liste aller VMs (qm list)
- Detaillierte VM Konfigurationen
- Liste aller Container (pct list)
- Detaillierte Container Konfigurationen

#### Network
- Netzwerk-Interfaces (ip addr)
- Netzwerk-Bridges (brctl show)
- Routing Table (ip route)
- Netzwerk-Konfigurationsdateien

#### Existing Homelab Setup
- Prüfung auf /root/proxmox-homelab Verzeichnis
- Git Status und Branches
- Ansible Playbooks
- README und Dokumentation

#### Backups
- Backup Konfiguration (/etc/pve/vzdump.cron)
- Backup Storage Inhalte

#### Security & Updates
- Verfügbare System-Updates
- Firewall Status
- Fail2ban Status

### Output

Die Scan-Ergebnisse werden in `/tmp/` gespeichert:
```
/tmp/proxmox-scan-<hostname>-<timestamp>.txt
```

## Methode 2: Standalone Bash Script

### Script auf Server kopieren

```bash
# Von deinem lokalen System
scp ansible/scripts/scan-proxmox-server.sh root@192.168.16.7:/tmp/

# Oder direkt auf dem Server erstellen
ssh root@192.168.16.7
cd /tmp
# Script-Inhalt einfügen
```

### Script ausführen

```bash
# Auf dem Proxmox Server
chmod +x /tmp/scan-proxmox-server.sh
/tmp/scan-proxmox-server.sh
```

Das Script:
- Sammelt die gleichen Informationen wie das Ansible Playbook
- Zeigt Fortschritt mit farbigen Status-Messages
- Erstellt einen detaillierten Report in `/tmp/`
- Zeigt eine Zusammenfassung am Ende

### Report ansehen

```bash
# Neuesten Report finden
ls -lt /tmp/proxmox-scan-* | head -1

# Report anzeigen
cat /tmp/proxmox-scan-pve-thinkpad-20241128_123456.txt

# Mit Pager (besser für lange Reports)
less /tmp/proxmox-scan-pve-thinkpad-20241128_123456.txt
```

## Zweiten Server hinzufügen

### 1. Inventory aktualisieren

Bearbeite `ansible/inventory/hosts.yml`:

```yaml
proxmox:
  hosts:
    pve-thinkpad:
      ansible_host: 192.168.16.7
      ansible_user: root
      ansible_port: 22
      ansible_python_interpreter: /usr/bin/python3

    pve2:  # <-- Zweiten Server hier hinzufügen
      ansible_host: 192.168.16.X  # <-- IP-Adresse anpassen
      ansible_user: root
      ansible_port: 22
      ansible_python_interpreter: /usr/bin/python3
```

### 2. SSH-Zugriff konfigurieren

```bash
# SSH Key zum zweiten Server kopieren
ssh-copy-id root@192.168.16.X

# Verbindung testen
ssh root@192.168.16.X "hostname"

# Mit Ansible testen
ansible pve2 -m ping
```

### 3. Beide Server scannen

```bash
# Alle Server gleichzeitig
ansible-playbook playbooks/server-scan.yml

# Server parallel scannen (schneller)
ansible-playbook playbooks/server-scan.yml --forks 2
```

## Scan-Ergebnisse analysieren

### Report-Struktur

Jeder Report enthält folgende Sections:

```
╔══════════════════════════════════════════════════════════════╗
║          SYSTEM INFORMATION                                  ║
╚══════════════════════════════════════════════════════════════╝
├── Hostname
├── Kernel & OS
├── CPU Info
├── Memory
└── Disk Usage

╔══════════════════════════════════════════════════════════════╗
║          PROXMOX INFORMATION                                 ║
╚══════════════════════════════════════════════════════════════╝
├── Version
├── Cluster Status
└── Services

╔══════════════════════════════════════════════════════════════╗
║          STORAGE                                             ║
╚══════════════════════════════════════════════════════════════╝
├── Proxmox Storage
├── ZFS (falls vorhanden)
└── LVM

╔══════════════════════════════════════════════════════════════╗
║          VIRTUAL MACHINES & CONTAINERS                       ║
╚══════════════════════════════════════════════════════════════╝
├── VM Liste & Konfigurationen
└── Container Liste & Konfigurationen

╔══════════════════════════════════════════════════════════════╗
║          NETWORK                                             ║
╚══════════════════════════════════════════════════════════════╝
├── Interfaces
├── Bridges
└── Routes

╔══════════════════════════════════════════════════════════════╗
║          EXISTING HOMELAB                                    ║
╚══════════════════════════════════════════════════════════════╝
└── /root/proxmox-homelab Analyse
```

### Wichtige Informationen extrahieren

```bash
# VMs zählen
grep "^VMID" /tmp/proxmox-scan-*.txt

# Container zählen
grep "^VMID.*lxc" /tmp/proxmox-scan-*.txt

# Storage Usage
grep -A 10 "=== Disk Usage ===" /tmp/proxmox-scan-*.txt

# Proxmox Version
grep -A 5 "=== Proxmox Version ===" /tmp/proxmox-scan-*.txt

# Verfügbare Updates
grep -A 20 "=== Available Updates ===" /tmp/proxmox-scan-*.txt
```

## Regelmäßige Scans

### Cron Job einrichten (optional)

```bash
# Auf jedem Proxmox Server
crontab -e

# Wöchentlicher Scan jeden Sonntag um 2 Uhr
0 2 * * 0 /root/scan-proxmox-server.sh

# Oder monatlich am 1. eines jeden Monats
0 2 1 * * /root/scan-proxmox-server.sh
```

### Ansible-gesteuerte regelmäßige Scans

```bash
# Von deinem Control-System (z.B. täglich)
0 3 * * * cd /path/to/ansible && ansible-playbook playbooks/server-scan.yml
```

## Troubleshooting

### SSH Connection Failed

```bash
# SSH-Verbindung manuell testen
ssh -v root@192.168.16.7

# SSH Key-Probleme
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.16.7

# Firewall prüfen
ssh root@192.168.16.7 "iptables -L -n | grep 22"
```

### Python nicht gefunden

```bash
# Python3 auf Proxmox installieren
ssh root@192.168.16.7 "apt update && apt install -y python3"
```

### Ansible Collection fehlt

```bash
# Alle erforderlichen Collections installieren
ansible-galaxy collection install -r requirements.yml --force
```

### Permission Denied

```bash
# Script ausführbar machen
chmod +x ansible/scripts/scan-proxmox-server.sh

# Root-Rechte prüfen
ssh root@192.168.16.7 "whoami"
```

## Best Practices

1. **Regelmäßig scannen**: Führe Scans vor und nach größeren Änderungen durch
2. **Reports archivieren**: Behalte historische Reports für Vergleiche
3. **Automatisierung**: Nutze Ansible für konsistente, wiederholbare Scans
4. **Dokumentation**: Notiere Änderungen und deren Gründe in den Reports
5. **Sicherheit**: Speichere Reports sicher, sie enthalten Infrastruktur-Details

## Nächste Schritte

Nach dem Scan kannst du:

1. **Vergleiche durchführen**: Reports von verschiedenen Zeitpunkten vergleichen
2. **Inventar erstellen**: Basierend auf Scan-Ergebnissen detailliertes Inventar führen
3. **Automation planen**: Playbooks für häufige Aufgaben entwickeln
4. **Monitoring einrichten**: Prometheus/Grafana für kontinuierliches Monitoring
5. **Backup-Strategie**: Basierend auf VM/Container-Liste Backup-Plan erstellen

## Beispiele

### Beispiel 1: Schneller Status-Check

```bash
# Nur System-Info und VM/Container-Liste
ansible proxmox -m shell -a "hostname && pveversion && qm list && pct list"
```

### Beispiel 2: Storage-Analyse

```bash
# Detaillierte Storage-Informationen
ansible-playbook playbooks/server-scan.yml --tags storage
```

### Beispiel 3: Cluster-Status

```bash
# Nur Cluster-Informationen
ansible proxmox -m shell -a "pvecm status && pvecm nodes"
```

### Beispiel 4: Reports vergleichen

```bash
# Zwei Reports vergleichen
diff /tmp/proxmox-scan-pve1-20241120_*.txt /tmp/proxmox-scan-pve1-20241128_*.txt
```

## Hilfreiche Kommandos

```bash
# Alle Proxmox Hosts auflisten
ansible proxmox --list-hosts

# Ansible Facts sammeln
ansible proxmox -m setup

# Ad-hoc Command ausführen
ansible proxmox -a "df -h"

# Mit erhöhter Verbosity
ansible-playbook playbooks/server-scan.yml -vvv
```

## Support & Erweiterungen

Das Scan-Playbook und Script können erweitert werden für:

- Custom Checks für spezifische Anwendungen
- Integration mit Monitoring-Systemen
- Automatische Report-Analyse und Alerting
- Export in verschiedene Formate (JSON, CSV, HTML)
- Integration mit Configuration Management Databases (CMDB)

Passe die Scripts nach deinen Bedürfnissen an!
