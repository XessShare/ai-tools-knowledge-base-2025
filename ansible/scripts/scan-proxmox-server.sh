#!/bin/bash

################################################################################
# Proxmox Server Comprehensive Scan Script
# This script collects detailed information about a Proxmox server
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Output file
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
HOSTNAME=$(hostname)
REPORT_FILE="/tmp/proxmox-scan-${HOSTNAME}-${TIMESTAMP}.txt"

echo -e "${BOLD}${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║          PROXMOX SERVER COMPREHENSIVE SCAN                   ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Function to print section header
print_section() {
    echo -e "\n${BOLD}${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${BLUE}│ $1${NC}"
    echo -e "${BOLD}${BLUE}└─────────────────────────────────────────────────────────────┘${NC}\n"
}

# Function to run command and log
run_command() {
    local description="$1"
    local command="$2"
    local required="${3:-false}"

    echo -e "${YELLOW}[*] ${description}${NC}"

    if eval "$command" 2>/dev/null; then
        echo -e "${GREEN}[✓] Success${NC}\n"
        return 0
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}[✗] Failed (required)${NC}\n"
            return 1
        else
            echo -e "${YELLOW}[!] Not available or failed (optional)${NC}\n"
            return 0
        fi
    fi
}

# Start report file
{
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    PROXMOX SERVER COMPREHENSIVE SCAN REPORT                  ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Scan Date: $(date)"
    echo "Hostname: ${HOSTNAME}"
    echo ""
} > "$REPORT_FILE"

################################################################################
# SYSTEM INFORMATION
################################################################################
print_section "SYSTEM INFORMATION" | tee -a "$REPORT_FILE"

{
    echo "=== Hostname ==="
    hostname
    echo ""

    echo "=== System Information ==="
    uname -a
    echo ""

    echo "=== OS Release ==="
    cat /etc/os-release
    echo ""

    echo "=== Uptime ==="
    uptime
    echo ""

    echo "=== CPU Information ==="
    lscpu
    echo ""

    echo "=== Memory Information ==="
    free -h
    echo ""

    echo "=== Disk Usage ==="
    df -h
    echo ""
} | tee -a "$REPORT_FILE"

################################################################################
# PROXMOX INFORMATION
################################################################################
print_section "PROXMOX INFORMATION" | tee -a "$REPORT_FILE"

{
    echo "=== Proxmox Version ==="
    pveversion --verbose
    echo ""

    echo "=== Cluster Status ==="
    if pvecm status 2>/dev/null; then
        echo ""
    else
        echo "Not in a cluster or cluster service not running"
        echo ""
    fi

    echo "=== Cluster Nodes ==="
    if pvecm nodes 2>/dev/null; then
        echo ""
    else
        echo "Not in a cluster"
        echo ""
    fi
} | tee -a "$REPORT_FILE"

################################################################################
# STORAGE INFORMATION
################################################################################
print_section "STORAGE INFORMATION" | tee -a "$REPORT_FILE"

{
    echo "=== Proxmox Storage ==="
    pvesm status
    echo ""

    echo "=== ZFS Pools ==="
    if zpool list 2>/dev/null; then
        echo ""
        echo "=== ZFS Datasets ==="
        zfs list
        echo ""
    else
        echo "No ZFS pools found"
        echo ""
    fi

    echo "=== LVM Physical Volumes ==="
    if pvs 2>/dev/null; then
        echo ""
    else
        echo "No LVM physical volumes found"
        echo ""
    fi

    echo "=== LVM Volume Groups ==="
    if vgs 2>/dev/null; then
        echo ""
    else
        echo "No LVM volume groups found"
        echo ""
    fi

    echo "=== LVM Logical Volumes ==="
    if lvs 2>/dev/null; then
        echo ""
    else
        echo "No LVM logical volumes found"
        echo ""
    fi

    echo "=== Block Devices ==="
    lsblk
    echo ""
} | tee -a "$REPORT_FILE"

################################################################################
# VIRTUAL MACHINES
################################################################################
print_section "VIRTUAL MACHINES" | tee -a "$REPORT_FILE"

{
    echo "=== VM List ==="
    qm list
    echo ""

    echo "=== VM Configurations ==="
    for vmid in $(qm list | awk 'NR>1 {print $1}'); do
        echo "--- VM $vmid ---"
        qm config "$vmid"
        echo ""
    done
} | tee -a "$REPORT_FILE"

################################################################################
# CONTAINERS
################################################################################
print_section "CONTAINERS" | tee -a "$REPORT_FILE"

{
    echo "=== Container List ==="
    pct list
    echo ""

    echo "=== Container Configurations ==="
    for ctid in $(pct list | awk 'NR>1 {print $1}'); do
        echo "--- Container $ctid ---"
        pct config "$ctid"
        echo ""
    done
} | tee -a "$REPORT_FILE"

################################################################################
# NETWORK CONFIGURATION
################################################################################
print_section "NETWORK CONFIGURATION" | tee -a "$REPORT_FILE"

{
    echo "=== Network Interfaces ==="
    ip addr show
    echo ""

    echo "=== Network Bridges ==="
    if brctl show 2>/dev/null; then
        echo ""
    else
        echo "Bridge utilities not available"
        echo ""
    fi

    echo "=== Routing Table ==="
    ip route show
    echo ""

    echo "=== Network Configuration File ==="
    cat /etc/network/interfaces
    echo ""

    echo "=== DNS Configuration ==="
    cat /etc/resolv.conf
    echo ""
} | tee -a "$REPORT_FILE"

################################################################################
# SERVICES
################################################################################
print_section "PROXMOX SERVICES" | tee -a "$REPORT_FILE"

{
    echo "=== Proxmox Service Status ==="
    for service in pve-cluster pvedaemon pveproxy pvestatd pvescheduler; do
        echo "--- $service ---"
        systemctl status "$service" --no-pager || echo "Service not running or not found"
        echo ""
    done

    echo "=== All Running Services ==="
    systemctl list-units --type=service --state=running --no-pager
    echo ""
} | tee -a "$REPORT_FILE"

################################################################################
# EXISTING HOMELAB STRUCTURE
################################################################################
print_section "EXISTING HOMELAB STRUCTURE" | tee -a "$REPORT_FILE"

{
    if [ -d "/root/proxmox-homelab" ]; then
        echo "=== Proxmox Homelab Directory Found ==="
        echo ""

        echo "--- Directory Contents ---"
        ls -lah /root/proxmox-homelab
        echo ""

        echo "--- All Files ---"
        find /root/proxmox-homelab -type f
        echo ""

        echo "--- README.md ---"
        if [ -f "/root/proxmox-homelab/README.md" ]; then
            cat /root/proxmox-homelab/README.md
        else
            echo "README.md not found"
        fi
        echo ""

        echo "--- CLAUDE.md ---"
        if [ -f "/root/proxmox-homelab/CLAUDE.md" ]; then
            cat /root/proxmox-homelab/CLAUDE.md
        else
            echo "CLAUDE.md not found"
        fi
        echo ""

        echo "--- Git Status ---"
        if [ -d "/root/proxmox-homelab/.git" ]; then
            cd /root/proxmox-homelab
            git status
            echo ""
            echo "--- Git Branches ---"
            git branch -a
            echo ""
            echo "--- Recent Commits ---"
            git log --oneline -10
            echo ""
        else
            echo "Not a git repository"
        fi

        echo "--- Ansible Playbooks ---"
        if [ -d "/root/proxmox-homelab/ansible" ]; then
            find /root/proxmox-homelab/ansible -name "*.yml" -o -name "*.yaml"
        else
            echo "No ansible directory found"
        fi
        echo ""

    else
        echo "No /root/proxmox-homelab directory found"
        echo ""
    fi
} | tee -a "$REPORT_FILE"

################################################################################
# BACKUPS
################################################################################
print_section "BACKUP CONFIGURATION" | tee -a "$REPORT_FILE"

{
    echo "=== Backup Cron Configuration ==="
    if [ -f "/etc/pve/vzdump.cron" ]; then
        cat /etc/pve/vzdump.cron
    else
        echo "No backup cron configuration found"
    fi
    echo ""

    echo "=== Backup Storage Contents ==="
    if [ -d "/var/lib/vz/dump" ]; then
        ls -lh /var/lib/vz/dump/
    else
        echo "No backup storage found"
    fi
    echo ""
} | tee -a "$REPORT_FILE"

################################################################################
# SECURITY & UPDATES
################################################################################
print_section "SECURITY & UPDATES" | tee -a "$REPORT_FILE"

{
    echo "=== Available Updates ==="
    apt list --upgradable 2>/dev/null
    echo ""

    echo "=== Firewall Status ==="
    if pve-firewall status 2>/dev/null; then
        echo ""
    else
        echo "Firewall not configured or not running"
        echo ""
    fi

    echo "=== Fail2ban Status ==="
    if systemctl status fail2ban --no-pager 2>/dev/null; then
        echo ""
    else
        echo "Fail2ban not installed or not running"
        echo ""
    fi

    echo "=== SSH Configuration ==="
    grep -E "^(Port|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)" /etc/ssh/sshd_config || echo "Default SSH configuration"
    echo ""
} | tee -a "$REPORT_FILE"

################################################################################
# SUMMARY
################################################################################
{
    echo ""
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo "End of Report - $(date)"
    echo ""
} >> "$REPORT_FILE"

echo -e "${BOLD}${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SCAN COMPLETE                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${GREEN}Report saved to: ${REPORT_FILE}${NC}"
echo ""
echo -e "${CYAN}Summary:${NC}"
echo -e "  - VMs: $(qm list | wc -l | awk '{print $1-1}')"
echo -e "  - Containers: $(pct list | wc -l | awk '{print $1-1}')"
echo -e "  - Homelab directory: $([ -d /root/proxmox-homelab ] && echo 'EXISTS' || echo 'NOT FOUND')"
echo ""
echo -e "${YELLOW}You can view the full report with:${NC}"
echo -e "  cat $REPORT_FILE"
echo -e "  or"
echo -e "  less $REPORT_FILE"
echo ""
