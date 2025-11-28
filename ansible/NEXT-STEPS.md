# Nächste Schritte - Proxmox Homelab Setup

## 🎯 Quick Start

### 1. SSH-Zugriff vorbereiten

```bash
# SSH Keys zu beiden Servern kopieren
ssh-copy-id root@192.168.16.7  # pve-thinkpad
ssh-copy-id root@192.168.17.1  # pve2

# Verbindung testen
ssh root@192.168.16.7 "hostname"
ssh root@192.168.17.1 "hostname"
```

### 2. Ansible Dependencies installieren

```bash
cd ansible

# Ansible Collections installieren
ansible-galaxy collection install -r requirements.yml

# Python Libraries für Proxmox API (optional)
pip3 install proxmoxer requests
```

### 3. Verbindung testen

```bash
# Alle Server testen
ansible proxmox -m ping

# Einzelnen Server testen
ansible pve-thinkpad -m ping
ansible pve2 -m ping
```

### 4. Ersten Scan durchführen

```bash
# Quick Scan (beide Server)
./scripts/quick-scan.sh

# Oder vollständiger Scan
ansible-playbook playbooks/server-scan.yml
```

## 📋 Verfügbare Server

| Hostname | IP-Adresse | Notizen |
|----------|-----------|---------|
| pve-thinkpad | 192.168.16.7 | Hat /root/proxmox-homelab |
| pve2 | 192.168.17.1 | Zweiter Proxmox Server |

## 🛠️ Verfügbare Playbooks

### 1. Server Scan
Umfassender Scan beider Server:
```bash
ansible-playbook playbooks/server-scan.yml
```

### 2. Proxmox Setup
Initiale Konfiguration (Packages, NTP, Timezone):
```bash
ansible-playbook playbooks/proxmox-setup.yml
```

### 3. Container deployen
LXC Container erstellen:
```bash
ansible-playbook playbooks/container-deploy.yml \
  -e "container_id=100" \
  -e "container_hostname=test-ct" \
  --limit pve-thinkpad
```

### 4. VM deployen
Virtuelle Maschine erstellen:
```bash
ansible-playbook playbooks/vm-deploy.yml \
  -e "vm_id=200" \
  -e "vm_name=test-vm" \
  --limit pve-thinkpad
```

### 5. Maintenance
System-Updates und Wartung:
```bash
ansible-playbook playbooks/maintenance.yml
```

## 🔍 Server analysieren

### Quick Info sammeln

```bash
# Hostname und Version
ansible proxmox -a "hostname && pveversion"

# VMs und Container zählen
ansible proxmox -m shell -a "echo VMs: \$(qm list | wc -l) && echo CTs: \$(pct list | wc -l)"

# Speichernutzung
ansible proxmox -m shell -a "df -h /"

# Uptime
ansible proxmox -a "uptime"
```

### Detaillierter Scan

```bash
# Beide Server scannen
ansible-playbook playbooks/server-scan.yml

# Nur einen Server
ansible-playbook playbooks/server-scan.yml --limit pve-thinkpad

# Mit höherer Verbosity (Debug)
ansible-playbook playbooks/server-scan.yml -vv
```

### Scan-Reports ansehen

Die Reports werden in `/tmp/` gespeichert:
```bash
# Auf lokalem System (nach Ansible-Scan)
ls -lt /tmp/proxmox-scan-*

# Direkt auf Server
ssh root@192.168.16.7 "ls -lt /tmp/proxmox-scan-*"
```

## 🔐 Sicherheit

### Ansible Vault einrichten

```bash
# Vault Password File erstellen
echo "your-secure-password" > .vault_pass
chmod 600 .vault_pass

# Vault File für Proxmox Credentials erstellen
ansible-vault create group_vars/proxmox/vault.yml --vault-password-file .vault_pass
```

Inhalt der `vault.yml`:
```yaml
---
vault_proxmox_password: "your-proxmox-password"
vault_proxmox_api_token_id: "your-api-token-id"
vault_proxmox_api_token_secret: "your-api-token-secret"
```

### Mit Vault arbeiten

```bash
# Playbook mit Vault ausführen
ansible-playbook playbooks/container-deploy.yml --vault-password-file .vault_pass

# Vault editieren
ansible-vault edit group_vars/proxmox/vault.yml --vault-password-file .vault_pass

# Vault anzeigen
ansible-vault view group_vars/proxmox/vault.yml --vault-password-file .vault_pass
```

## 📊 /root/proxmox-homelab analysieren

Auf pve-thinkpad existiert bereits `/root/proxmox-homelab`. Analysiere den Inhalt:

```bash
# Dateien auflisten
ssh root@192.168.16.7 "ls -lah /root/proxmox-homelab"

# README lesen
ssh root@192.168.16.7 "cat /root/proxmox-homelab/README.md"

# Git Status prüfen
ssh root@192.168.16.7 "cd /root/proxmox-homelab && git status"

# Ansible Playbooks finden
ssh root@192.168.16.7 "find /root/proxmox-homelab/ansible -name '*.yml'"

# Oder mit Ansible
ansible pve-thinkpad -m shell -a "ls -lah /root/proxmox-homelab"
```

## 🎨 Nächste Entwicklungsschritte

### 1. Cluster-Setup (optional)
Wenn beide Server ein Cluster bilden sollen:
- Cluster-Konfiguration mit `pvecm`
- Shared Storage (Ceph, NFS, etc.)
- HA-Konfiguration

### 2. Custom Roles erstellen
Wiederverwendbare Ansible Roles für:
- Docker Container
- Webserver (nginx, apache)
- Datenbanken (PostgreSQL, MySQL)
- Monitoring (Prometheus, Grafana)
- Reverse Proxy (Traefik, nginx)

### 3. Automation erweitern
- Automatische Backups
- VM/CT Templates
- Snapshot-Management
- Resource Monitoring
- Alert-System

### 4. Netzwerk-Konfiguration
- VLANs einrichten
- Firewall-Regeln
- VPN-Zugang
- DNS-Server

### 5. CI/CD Integration
- GitLab/GitHub Actions
- Automatische Deployments
- Testing Pipeline
- Infrastructure as Code

## 🐛 Troubleshooting

### SSH funktioniert nicht
```bash
# Verbose SSH Test
ssh -v root@192.168.16.7

# SSH Key nochmal kopieren
ssh-copy-id -f root@192.168.16.7

# Mit Passwort-Auth testen
ssh -o PubkeyAuthentication=no root@192.168.16.7
```

### Ansible kann Server nicht erreichen
```bash
# Mit erhöhter Verbosity
ansible proxmox -m ping -vvv

# Inventory testen
ansible-inventory --list

# Hosts auflisten
ansible proxmox --list-hosts

# Einzelner Host
ansible pve-thinkpad -m ping -vvv
```

### Python nicht gefunden
```bash
# Python auf Server installieren
ssh root@192.168.16.7 "apt update && apt install -y python3"
ssh root@192.168.17.1 "apt update && apt install -y python3"

# Oder mit Ansible (wenn Verbindung funktioniert)
ansible proxmox -m raw -a "apt update && apt install -y python3"
```

### Proxmox API funktioniert nicht
```bash
# API Token erstellen (auf Proxmox Web UI)
# Datacenter -> API Tokens -> Add

# Oder Passwort-basiert arbeiten (weniger sicher)
# In hosts.yml: proxmox_api_password verwenden
```

## 📚 Dokumentation

- **README.md** - Hauptdokumentation mit allen Playbooks
- **SCAN-GUIDE.md** - Detaillierte Scan-Anleitung
- **NEXT-STEPS.md** - Diese Datei

## 🤝 Best Practices

1. **Immer testen**: Nutze `--check` für Dry-Runs
2. **Backups**: Vor größeren Änderungen Backups erstellen
3. **Version Control**: Alle Änderungen committen
4. **Dokumentation**: Änderungen dokumentieren
5. **Secrets**: Niemals Passwörter in Git committen
6. **Incremental**: Kleine Schritte, oft testen

## 🎯 Sofortige Aktionen

### Option A: Schnelle Übersicht
```bash
cd ansible
chmod +x scripts/quick-scan.sh
./scripts/quick-scan.sh
```

### Option B: Detaillierter Scan
```bash
cd ansible
ansible-playbook playbooks/server-scan.yml
# Reports in /tmp/ prüfen
```

### Option C: Manuelle Erkundung
```bash
# Server 1
ssh root@192.168.16.7
hostname
pveversion
qm list
pct list
df -h
exit

# Server 2
ssh root@192.168.17.1
hostname
pveversion
qm list
pct list
df -h
exit
```

## ❓ Fragen zu klären

- [ ] Sollen beide Server ein Cluster bilden?
- [ ] Welche Workloads sollen deployed werden?
- [ ] Gibt es bevorzugte Storage-Typen? (local-lvm, ZFS, Ceph?)
- [ ] Wird Backup-Lösung benötigt?
- [ ] Monitoring gewünscht? (Prometheus/Grafana)
- [ ] VPN-Zugriff erforderlich?
- [ ] Welche Services sollen automatisiert werden?

---

**Viel Erfolg mit deinem Proxmox Homelab! 🚀**
