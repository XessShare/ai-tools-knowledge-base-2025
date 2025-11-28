# Proxmox Homelab Ansible Automation

Ansible playbooks and configuration for managing a Proxmox homelab environment.

## Prerequisites

- Ansible 2.9 or higher installed on your control machine
- SSH access to your Proxmox host (root@192.168.16.7)
- Python 3.x on the control machine
- Proxmox VE 7.x or higher

## Quick Start

### 1. Install Ansible and Dependencies

```bash
# On Ubuntu/Debian
sudo apt update
sudo apt install ansible python3-pip

# On macOS
brew install ansible

# Install Python dependencies
pip3 install proxmoxer requests
```

### 2. Install Required Ansible Collections

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

### 3. Configure SSH Access

Ensure you can SSH to your Proxmox host without password:

```bash
# Test SSH connection
ssh root@192.168.16.7

# If not set up, copy your SSH key
ssh-copy-id root@192.168.16.7
```

### 4. Update Inventory

Edit `ansible/inventory/hosts.yml` to match your environment:
- Update IP addresses
- Configure timezone
- Set NTP servers
- Add Proxmox API credentials (optional, for VM/CT management)

### 5. Test Connectivity

```bash
cd ansible
ansible proxmox -m ping
```

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── requirements.yml         # Required collections and roles
├── inventory/
│   └── hosts.yml           # Inventory file with Proxmox hosts
├── group_vars/
│   └── all.yml             # Global variables
├── host_vars/              # Host-specific variables
├── playbooks/
│   ├── site.yml            # Main playbook
│   ├── proxmox-setup.yml   # Initial Proxmox configuration
│   ├── container-deploy.yml # LXC container deployment
│   ├── vm-deploy.yml       # VM deployment
│   └── maintenance.yml     # Maintenance tasks
└── roles/                  # Custom roles (future)
```

## Available Playbooks

### Proxmox Initial Setup

Configure your Proxmox host with essential packages and settings:

```bash
cd ansible
ansible-playbook playbooks/proxmox-setup.yml
```

This playbook:
- Updates system packages
- Installs essential tools (vim, htop, git, etc.)
- Configures timezone and NTP
- Displays Proxmox version and cluster status

### Deploy LXC Container

Deploy a new LXC container:

```bash
cd ansible
ansible-playbook playbooks/container-deploy.yml \
  -e "container_id=100" \
  -e "container_hostname=webserver" \
  -e "container_memory=2048"
```

Variables you can customize:
- `container_id`: Container VMID (default: 100)
- `container_hostname`: Container hostname
- `container_password`: Root password (default: changeme)
- `container_ostemplate`: OS template to use
- `container_memory`: RAM in MB (default: 2048)
- `container_cores`: CPU cores (default: 2)
- `container_disk`: Disk size in GB (default: 8)

### Deploy Virtual Machine

Deploy a new VM:

```bash
cd ansible
ansible-playbook playbooks/vm-deploy.yml \
  -e "vm_id=200" \
  -e "vm_name=debian-vm" \
  -e "vm_memory=4096"
```

Variables you can customize:
- `vm_id`: VM VMID (default: 200)
- `vm_name`: VM name
- `vm_memory`: RAM in MB (default: 4096)
- `vm_cores`: CPU cores (default: 2)
- `vm_disk_size`: Disk size (default: 32G)
- `vm_iso`: ISO image to use

### Maintenance Tasks

Run maintenance tasks:

```bash
cd ansible

# Update all packages
ansible-playbook playbooks/maintenance.yml --tags update

# Check system info
ansible-playbook playbooks/maintenance.yml --tags info

# Clean up logs
ansible-playbook playbooks/maintenance.yml --tags cleanup

# Check services
ansible-playbook playbooks/maintenance.yml --tags services
```

## Common Operations

### Run All Setup Tasks

```bash
cd ansible
ansible-playbook playbooks/site.yml
```

### Run Specific Tags

```bash
# Only install packages
ansible-playbook playbooks/proxmox-setup.yml --tags packages

# Only system configuration
ansible-playbook playbooks/proxmox-setup.yml --tags system
```

### Dry Run (Check Mode)

```bash
ansible-playbook playbooks/proxmox-setup.yml --check
```

### Verbose Output

```bash
ansible-playbook playbooks/proxmox-setup.yml -v   # Verbose
ansible-playbook playbooks/proxmox-setup.yml -vvv # Very verbose
```

## Security Best Practices

### Using Ansible Vault for Secrets

Store sensitive data (passwords, API tokens) in encrypted vault files:

```bash
# Create vault password file
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass

# Create encrypted vault file
ansible-vault create group_vars/proxmox/vault.yml --vault-password-file .vault_pass

# Add your secrets
---
vault_proxmox_password: "your-proxmox-password"
vault_proxmox_api_token_id: "your-token-id"
vault_proxmox_api_token_secret: "your-token-secret"

# Reference in inventory (already configured in hosts.yml)
proxmox_api_password: "{{ vault_proxmox_password }}"

# Run playbook with vault
ansible-playbook playbooks/container-deploy.yml --vault-password-file .vault_pass
```

### SSH Key Authentication

Always use SSH keys instead of passwords:

```bash
ssh-keygen -t ed25519 -C "ansible@homelab"
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.16.7
```

## Troubleshooting

### Cannot connect to Proxmox host

```bash
# Test SSH connection
ssh -v root@192.168.16.7

# Test Ansible connectivity
ansible proxmox -m ping -vvv
```

### Python not found on Proxmox host

```bash
# Install Python on Proxmox
ssh root@192.168.16.7 "apt update && apt install -y python3"
```

### API authentication issues

Ensure your API credentials are correct in `inventory/hosts.yml` or use password authentication initially.

## Next Steps

1. **Customize Variables**: Edit `group_vars/all.yml` and `inventory/hosts.yml` to match your environment
2. **Create Roles**: Build reusable roles for specific services (web servers, databases, etc.)
3. **Add More Playbooks**: Create playbooks for specific applications or configurations
4. **Set Up Vault**: Encrypt sensitive data using Ansible Vault
5. **Automate Backups**: Create playbooks for VM/CT backup and restore
6. **Network Configuration**: Add playbooks for network bridge and VLAN configuration

## Useful Commands

```bash
# List all hosts
ansible all --list-hosts

# Check inventory
ansible-inventory --list

# Run ad-hoc commands
ansible proxmox -m command -a "pveversion"
ansible proxmox -m shell -a "qm list"
ansible proxmox -m shell -a "pct list"

# Gather facts
ansible proxmox -m setup
```

## Resources

- [Proxmox Documentation](https://pve.proxmox.com/pve-docs/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Community.General Collection](https://docs.ansible.com/ansible/latest/collections/community/general/)
- [Proxmox API Documentation](https://pve.proxmox.com/pve-docs/api-viewer/)

## License

See LICENSE file for details.
