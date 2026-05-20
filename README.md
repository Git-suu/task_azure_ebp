# Deployment Status & Cleanup ✅

**Cleanup Confirmation:**
- ✅ All compute resources (VMs) terminated
- ✅ All networking resources (VNet, subnets, NSGs) deleted  
- ✅ All storage resources cleaned up
- ✅ Public IPs de-allocated
- ✅ Resource group deleted
- ✅ No ongoing Azure charges

**Command Used:** `terraform destroy -auto-approve`

**Verification:** All resources confirmed destroyed via Azure CLI

---

# 1. Introduction

This project demonstrates the design and deployment of a secure, scalable, and cost-conscious cloud infrastructure platform for a small remote engineering team.

The objective of the assignment was to:

* Design a realistic cloud architecture
* Implement the infrastructure using Infrastructure as Code (Terraform)
* Deploy a working prototype environment
* Apply secure networking principles
* Consider startup-level cost optimization
* Support future scalability and operational improvements

The solution was implemented using Microsoft Azure and Terraform.

---

# 2. Problem Statement Understanding

The requirements described a startup environment where:

* Multiple remote engineers need secure access
* Frontend applications must be publicly reachable
* Backend services and databases must remain private
* Internal tools must not be internet-facing
* Costs must remain controlled
* Infrastructure must be reproducible

The architecture therefore focused on:

* Network segmentation
* Private backend isolation
* Infrastructure automation
* Simple operational overhead
* Future scalability support

---

# 3. Cloud Provider Choice

## Why Azure

Microsoft Azure was selected for the following reasons:

### Strong Networking Features

Azure provides:

* Virtual Networks (VNets)
* Network Security Groups (NSGs)
* VPN connectivity
* Private networking
* Bastion services
* Application Gateway support

These services are highly suitable for secure startup environments.

---

### Terraform Compatibility

Azure has mature Terraform provider support:

* Reliable resource provisioning
* Declarative infrastructure management
* Easier reproducibility
* Environment consistency

This aligns well with Infrastructure as Code best practices.

---

### Cost Optimization

Azure provides:

* Small VM sizes
* Pay-as-you-go pricing
* Good free-tier support
* Flexible scaling

This fits startup operational constraints.

---

# 4. Architecture Overview

## High-Level Architecture

This Terraform project creates a complete three-tier architecture on Azure with the following components:

```
┌─────────────────────────────────────────────────────────────┐
│                     Azure VNet (10.0.0.0/16)               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ PUBLIC SUBNET (10.0.1.0/24)                         │   │
│  │  └─ Frontend VM (Nginx)                             │   │
│  │     └─ Public IP: Frontend accessible via HTTP      │   │
│  │     └─ Security: HTTP (80), SSH (22)               │   │
│  └─────────────────────────────────────────────────────┘   │
│                            │                                 │
│                            ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ PRIVATE SUBNET (10.0.2.0/24)                        │   │
│  │  └─ Backend VM (FastAPI/Python)                     │   │
│  │     └─ Private IP: Accessible only from VNet        │   │
│  │     └─ Port 8000: FastAPI service                   │   │
│  │     └─ Security: Port 8000 from Public Subnet only  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ DATA SUBNET (10.0.3.0/24)                           │   │
│  │  └─ Reserved for databases/data services            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ GATEWAY SUBNET (10.0.4.0/24)                        │   │
│  │  └─ VPN Gateway                                     │   │
│  │     └─ RouteBased VPN Gateway (VpnGw1AZ)           │   │
│  │     └─ Static Public IP for VPN connections        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## 🏗️ Infrastructure Components

### Azure Resource Group
- **Name**: rg-ebp-devtasks
- **Location**: Central India
- Container for all resources in this project

### Virtual Network (VNet)
- **Name**: ebp-vnet
- **Address Space**: 10.0.0.0/16
- **Location**: Central India

### Subnets

| Subnet | CIDR Block | Purpose | Notes |
|--------|-----------|---------|-------|
| public-subnet | 10.0.1.0/24 | Frontend tier | Web server hosting |
| private-subnet | 10.0.2.0/24 | Backend/Application tier | API services |
| data-subnet | 10.0.3.0/24 | Database tier | Reserved for databases |
| GatewaySubnet | 10.0.4.0/24 | VPN Gateway | Required by Azure |

### Virtual Machines

#### Frontend VM
- **Name**: frontend-vm
- **OS**: Ubuntu 22.04 LTS
- **Size**: Standard_B1s
- **Subnet**: public-subnet
- **Public IP**: Yes
- **Installed**: Nginx web server
- **Port**: 80 (HTTP)
- **Custom Script**: Deploys Nginx and serves default page

#### Backend VM
- **Name**: backend-vm
- **OS**: Ubuntu 22.04 LTS
- **Size**: Standard_B1s
- **Subnet**: private-subnet
- **Public IP**: No (Private only)
- **Installed**: Python 3, FastAPI, Uvicorn
- **Port**: 8000 (FastAPI API)
- **Custom Script**: Deploys FastAPI application running on port 8000

### Network Security Groups (NSG)

#### Public NSG
- Applied to: public-subnet
- **Inbound Rules**:
  - HTTP (Port 80): Allow from anywhere
  - SSH (Port 22): MY IP
  
#### Private NSG
- Applied to: private-subnet
- **Inbound Rules**:
  - FastAPI (Port 8000): Allow from public-subnet (10.0.1.0/24) only

### VPN Gateway
- **Name**: vpn-gateway
- **Type**: RouteBased VPN
- **SKU**: VpnGw1AZ (Zone-Redundant)
- **Active-Active**: Disabled
- **Public IP**: Static allocation
- **Purpose**: Site-to-Site or Point-to-Site VPN connectivity

## 📁 Project Structure

```
terraform-project/
├── main.tf                 # Main configuration (Resource Group)
├── providers.tf            # Terraform version and Azure provider setup
├── variables.tf            # Variable definitions with defaults
├── networking.tf           # VNet, Subnets configuration
├── vm.tf                   # Virtual Machines and NICs setup
├── security.tf             # Network Security Groups and rules
├── vpn.tf                  # VPN Gateway configuration
├── outputs.tf              # Output values for access info
├── terraform.tfvars        # Variable values (auto-loaded)
├── terraform.tfstate       # State file (contains deployed resources)
├── terraform.tfstate.backup # State file backup
├── cloud-init/             # VM initialization scripts
│   ├── frontend.sh         # Frontend VM setup script
│   └── backend.sh          # Backend VM setup script
└── README.md              # This file
```

## 🔧 Configuration Variables

Edit `terraform.tfvars` or pass variables to customize:

| Variable | Default | Description |
|----------|---------|-------------|
| location | Central India | Azure region for resources |
| resource_group_name | rg-ebp-devtasks | Resource group name |
| admin_username | localuser | VM admin username |
| admin_password | Password1234! | VM admin password ⚠️ Change this! |

## 📋 Prerequisites

1. **Terraform** v1.5.0 or higher
   - [Download Terraform](https://www.terraform.io/downloads.html)
   
2. **Azure CLI** 
   - [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
   
3. **Azure Subscription**
   - Active Azure subscription with appropriate permissions

## 🚀 Quick Start

### 1. Initialize Terraform

```bash
terraform init
```

This downloads and installs the required Azure provider (azurerm ~3.100).

### 2. Preview Changes

```bash
terraform plan
```

Review the resources that will be created.

### 3. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm. Deployment typically takes 5-10 minutes.

### 4. Access Your Infrastructure

After deployment, run:
```bash
terraform output
```

This displays:
- `frontend_public_ip`: The public IP of your frontend VM
- `frontend_url`: Direct URL to access the frontend (http://IP)

## 💻 Accessing the VMs

### Frontend VM (Nginx)
```bash
# Get the public IP
terraform output frontend_public_ip

# Access via browser
# http://<public_ip>

# Or SSH into the VM
ssh -i your_key localuser@<public_ip>
```

### Backend VM (FastAPI)
```bash
# The backend VM has no public IP
# Access it from the frontend VM:

ssh localuser@<frontend_public_ip>

# Then from frontend, connect to backend:
curl http://10.0.2.4:8000/
```

## 🔒 Security Considerations

1. **Change Default Credentials**: Update `admin_password` in `terraform.tfvars`
2. **Use Key-Based Authentication**: Generate and use SSH keys instead of passwords
3. **Restrict SSH Access**: Modify security rules to allow SSH only from specific IPs
4. **Enable Disk Encryption**: Add managed disk encryption for sensitive data
5. **Use Secrets Management**: Store credentials in Azure Key Vault
6. **Network Isolation**: Private subnet correctly isolates backend from internet

## 📤 VPN Gateway Usage

The VPN gateway is provisioned and ready for:
- **Point-to-Site (P2S) VPN**: Connect individual computers to Azure VNet
- **Site-to-Site (S2S) VPN**: Connect on-premises network to Azure VNet

To configure VPN connections, see [Azure VPN Gateway Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/).

## 📊 Terraform State

The project maintains state files:
- `terraform.tfstate`: Current state
- `terraform.tfstate.backup`: Backup of previous state

⚠️ **Important**: 
- Never commit `.tfstate` files to public repositories
- Use remote state backend (Azure Storage) for team environments
- A `.gitignore` file should exclude state files

## 🗑️ Cleanup

To destroy all resources and avoid charges:

```bash
terraform destroy
```

Type `yes` when prompted. This typically takes 5-10 minutes.

## 📝 Cloud-Init Scripts

### frontend.sh
- Installs Nginx
- Creates default homepage
- Enables and starts Nginx service

### backend.sh
- Installs Python 3 and pip
- Installs FastAPI and Uvicorn
- Creates a simple FastAPI application
- Starts the API server on port 8000

## 🔄 Updating Infrastructure

To modify infrastructure:

1. Edit the appropriate `.tf` file
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes

Common modifications:
- **Change VM size**: Edit `size` in vm.tf
- **Modify security rules**: Edit security.tf
- **Add more subnets**: Add resource blocks to networking.tf

## 🐛 Troubleshooting

### Issue: Authentication failed
```bash
# Run Azure login
az login

# Or set credentials
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
```

### Issue: Deployment timeout
- Check your internet connection
- Verify Azure subscription has sufficient quota
- Check Azure Portal for any service issues

### Issue: Cannot reach backend from frontend
- Verify security group rules allow port 8000 from public subnet
- SSH into frontend and check connectivity: `curl http://10.0.2.4:8000/`

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Networking Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/networking-architectures)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/overview/index.html)

