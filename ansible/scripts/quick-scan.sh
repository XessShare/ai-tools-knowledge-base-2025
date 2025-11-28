#!/bin/bash

################################################################################
# Quick Scan - Beide Proxmox Server scannen
# Führt einen schnellen Scan beider Proxmox Server durch
################################################################################

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# Verzeichnis bestimmen
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BOLD}${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║          PROXMOX SERVERS QUICK SCAN                          ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

cd "$ANSIBLE_DIR"

echo -e "${YELLOW}[1/5] Teste Verbindung zu allen Servern...${NC}"
if ansible proxmox -m ping; then
    echo -e "${GREEN}✓ Alle Server erreichbar${NC}\n"
else
    echo -e "${RED}✗ Einige Server nicht erreichbar${NC}\n"
    echo -e "${YELLOW}Möchtest du trotzdem fortfahren? (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${YELLOW}[2/5] Sammle grundlegende Informationen...${NC}"
ansible proxmox -m shell -a "hostname && date" --one-line
echo ""

echo -e "${YELLOW}[3/5] Prüfe Proxmox Versionen...${NC}"
ansible proxmox -m shell -a "pveversion" --one-line
echo ""

echo -e "${YELLOW}[4/5] Zähle VMs und Container...${NC}"
echo -e "${BLUE}=== Virtual Machines ===${NC}"
ansible proxmox -m shell -a "qm list"
echo ""

echo -e "${BLUE}=== Containers ===${NC}"
ansible proxmox -m shell -a "pct list"
echo ""

echo -e "${YELLOW}[5/5] Prüfe Speichernutzung...${NC}"
ansible proxmox -m shell -a "df -h | grep -E '(Filesystem|/$|/dev/)'"
echo ""

echo -e "${BOLD}${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    QUICK SCAN ABGESCHLOSSEN                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${GREEN}Für einen detaillierten Scan verwende:${NC}"
echo -e "  ${BOLD}ansible-playbook playbooks/server-scan.yml${NC}"
echo ""
echo -e "${GREEN}Für einzelne Server:${NC}"
echo -e "  ${BOLD}ansible-playbook playbooks/server-scan.yml --limit pve-thinkpad${NC}"
echo -e "  ${BOLD}ansible-playbook playbooks/server-scan.yml --limit pve2${NC}"
echo ""
