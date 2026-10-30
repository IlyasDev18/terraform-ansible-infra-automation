# Enterprise Infrastructure-as-Code: Automated Node Provisioning, OS Hardening & Container Runtime Suite

![Terraform](https://img.shields.io/badge/Terraform-1.8+-844FBA?style=flat-square&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-2.15+-EE0000?style=flat-square&logo=ansible&logoColor=white)
![Linux Hardening](https://img.shields.io/badge/Security-Kernel%20Hardened-success?style=flat-square&logo=linux&logoColor=white)

A production-ready Infrastructure-as-Code (IaC) repository demonstrating end-to-end automated provisioning, OS security baseline enforcement, and container runtime orchestration across declarative target Linux nodes.

---

## 📐 System Architecture

This repository strictly separates concerns into a **Declarative Provisioning Layer** (Terraform) and an **Idempotent Configuration & Hardening Layer** (Ansible), forming a zero-touch infrastructure pipeline.

                      +-----------------------------------+
                      |     DevOps Control Station        |
                      |  (Terraform CLI + Ansible Engine) |
                      +-----------------------------------+
                                |              |
       [1] Provision & Network |              | [2] SSH Management Loop
           Bridge Setup        v              v     (Ports 2221, 2222)
      +---------------------------------------------------+
      |         Isolated Network: ansible_lab_network     |
      |                                                   |
      |   +-------------------+   +-------------------+   |
      |   |  Node-01 (Ubuntu) |   |  Node-02 (Ubuntu) |   |
      |   |  - Kernel Hardened|   |  - Kernel Hardened|   |
      |   |  - Docker Runtime |   |  - Docker Runtime |   |
      |   +-------------------+   +-------------------+   |
      +---------------------------------------------------+

---

## 🛠️ Repository Layout

```text
terraform-ansible-infra-automation/
├── terraform/                       # Infrastructure Provisioning Layer
│   ├── main.tf                      # Network bridges, container node resources & provider specs
│   ├── variables.tf                 # Parametrized node scaling & port mapping variables
│   └── outputs.tf                   # Dynamic IP/Port exports for upstream Ansible dynamic targets
└── ansible/                         # Configuration Management & Hardening Layer
    ├── inventory.ini                # Host connectivity inventory with SSH overrides
    └── playbooks/
        ├── 01-sysctl-hardening.yml  # Kernel networking protection & file permission lockdown
        └── 02-docker-install.yml    # Upstream GPG key validation, APT repo setup & Docker Engine
```
---

## ⚡ Core Technical Features & Hardening Standards

1. Provisioning & Networking (Terraform Layer)
Modular Node Scaling: Parameterized node definitions (variables.tf) allow instant cluster expansion by modifying instance counts.

Network Isolation: Automatically builds a dedicated virtual bridge network (ansible_lab_network) isolating node-to-node communication.

Deterministic Port Forwarding: Automatically calculates and binds dynamic target SSH ports (2221+N) to localhost for local control-plane accessibility.

2. OS Hardening & Security Baseline (01-sysctl-hardening.yml)
SYN Flood Protection: Enforces net.ipv4.tcp_syncookies = 1 to mitigate TCP connection exhaustion attacks.

Routing Security: Disables ICMP redirect acceptance (net.ipv4.conf.all.accept_redirects = 0) and packet forwarding (send_redirects = 0) to prevent Man-in-the-Middle (MitM) route poisoning.

Least-Privilege File Permissions: Enforces 0600 (root:root) strict file access controls on sensitive system credential stores (/etc/shadow).

3. Automated Container Runtime Engine (02-docker-install.yml)
Cryptographic Repository Verification: Provisions official Docker GPG keys into standard system keyrings (/etc/apt/keyrings).

Upstream APT Management: Registers official Docker stable architecture channels (amd64).

Complete Container Engine Suite: Installs docker-ce, docker-ce-cli, and containerd.io runtime primitives with full system service startup enablement.

## 🚀 Step-by-Step Deployment Guide
Prerequisites
Linux / WSL2 Control Node

terraform >= 1.8.0 or tofu >= 1.6.0

ansible >= 2.15 (installed via pipx or python venv)

Active Docker Daemon

Step 1: Provision Infrastructure with Terraform
Navigate to the terraform/ directory, initialize providers, and apply the infrastructure manifest:
```
Bash
cd terraform

* Initialize provider plugins (Kreuzwerker Docker Engine provider)
terraform init

* Review execution plan
terraform plan

* Provision network bridge and compute nodes
terraform apply -auto-approve
Expected Output Matrix:
Plaintext
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:
ansible_inventory_format = [
  "node-01 ansible_host=127.0.0.1 ansible_port=2221 ansible_user=root ansible_password=root",
  "node-02 ansible_host=127.0.0.1 ansible_port=2222 ansible_user=root ansible_password=root",
]
node_ip = "127.0.0.1"
node_ports = [ 2221, 2222 ]
Step 2: OS Hardening & Package Orchestration via Ansible
Move into the ansible/ directory and execute the playbooks sequentially:

Bash
cd ../ansible

# 1. Execute Linux Kernel & OS Hardening Playbook
ansible-playbook -i inventory.ini playbooks/01-sysctl-hardening.yml

# 2. Provision Container Engine Architecture
ansible-playbook -i inventory.ini playbooks/02-docker-install.yml
Ansible Execution Recap Sample:
Plaintext
PLAY RECAP *****************************************************************************************
node-01                    : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0
node-02                    : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0
🔍 Validation & Post-Deployment Audit
To verify infrastructure compliance without opening interactive SSH sessions, run ad-hoc Ansible diagnostic commands:

Bash
# 1. Verify SSH Connectivity Across All Cluster Nodes
ansible nodes -m ping -i inventory.ini

# 2. Audit Container Engine Binary Installation Across Cluster
ansible nodes -m command -a "docker --version" -i inventory.ini

# 3. Verify Security Baseline Enforcement (/etc/shadow permissions)
ansible nodes -m command -a "stat -c '%a %U:%G' /etc/shadow" -i inventory.ini
```
## 🧪 Idempotency & Compliance Testing
This codebase strictly adheres to Idempotent Execution Principles. Re-running any playbook against an already-configured node yields changed=0, confirming that no unintended drift or state mutation occurs on existing nodes:

Bash
ansible-playbook -i inventory.ini playbooks/02-docker-install.yml
Plaintext
PLAY RECAP *****************************************************************************************
node-01                    : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0
node-02                    : ok=6    changed=0    unreachable=0    failed=0    skipped=0