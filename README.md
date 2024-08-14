## check-point-se-lab

<div align="center">
  <h2><strong>The fully IaC Check Point SE Lab</strong></h2>
</div>

<div align="center">
<img src="images/locoslogo.jpg" alt="Screenshot" width="500">
</div>

**This kit contains a fully modular, scalable, and customizable IaC Cloud lab designed to be deployed in Microsoft Azure.**

**developed by**

**Raffi Ali/Massive, Hector Mora/Raven, Frank Rivas/Franktronic, and Travis Lockman/Antaeus**

**tHe fLoRiDa tEaM**

# Lab Environment Overview

This lab environment is designed to be executed from any Linux platform and deploys resources into Microsoft Azure. It utilizes Python, Terraform, Ansible, and Docker to automate the creation and management of the lab infrastructure.

## Components

### Python
- **`THE_CONTROLLER.py`**  
  Oversees the execution of all code, manages processes, and handles output across the platform.

- **`THE_DESTROYER.py`**  
  Destroys all resources built for the lab after the work is complete.

### Terraform
- **`terraform.tfvars.example`**  
  Template for Terraform variables. Remove the `.example` extension to use it as the variable file for Terraform.

- **`variables.tf`**  
  Do not modify this file! It contains the variable declaration and definition for the whole Terraform infrastructure.  You may add additional variables at the bottom without breaking the lab.

- **`core_azure_backbone.tf`**  
  Creates the backbone network for each student, consisting of one VNet with three subnets: internal, external, and DMZ.

- **`core_azure_student_VDIs.tf`**  
  Provisions one Windows VDI per student, pre-configured with necessary software.

- **`core_azure_ubuntu_docker_main.tf`**  
  Creates one Ubuntu server per student.

- **`core_azure_cpmanager.tf`**  
  Deploys one Check Point Manager per student.

- **`core_azure_cpgw01.tf`**  
  Creates one Check Point Gateway per student.

### Ansible
- **`ansible.cfg`**  
  Configures key options required to run Ansible for deploying the lab environment.

- **`core_ansible_create_docker_backbone.yaml`**  
  Installs and configures Docker on student Ubuntu machines, along with additional configurations.

  **`cp-se-lab-ansible-secrets.yaml`**  
  NOT INCLUDED IN REPO - Ansible secrets must be configured using this filename for deployment to work.

  **`cp-se-lab-vault-pass.txt`**  
  NOT INCLUDED IN REPO - This text file will store your vault password locally.  Must be named exact to above for deployment to work.

### Custom Folder
- This folder contains our customizations for the lab, and the files within are not supported on this project.  Anything you place in this folder will be automatically copied into your project folder.

## **Deployment summary**
1. Ready your Linux environment, Ubuntu is preferred, follow instructions below. 
2. Ready your Azure environment, see below for walkthrough.
3. Ready your local Ansible secrets vault and vault file.
```bash
ansible-vault create cp-se-lab-ansible-secrets.yaml
```
4. Clone this repository to your local machine.
5. Rename `terraform.tfvars.example` to `terraform.tfvars` and customize it with your environments details and secrets.
6. Turn on different features and enable your customizations through commenting/uncommenting or adding lines below the magic main portion of 'THE_CONTROLLER.py'
7. Run `THE_CONTROLLER.py`to start the lab environment setup.
```python
python3 THE_CONTROLLER.py
```
8. Once finished, execute `THE_DESTROYER.py` to clean up all resources.
```python
python3 THE_DESTROYER.py
```
# Lab Environment Setup

## Prerequisites

Ensure that you have the following installed on your Linux machine:

- Python
- Terraform
- Ansible
- sshpass

## Environment Preparation

### Linux Requirements
- **Ubuntu is preferred**: Make sure your system is updated before proceeding.
- **Install the following tools**:
  - Terraform
  - Ansible
  - sshpass

### Ansible Preparation
- **sshpass Installation**: Required for running Ansible with username and password on the Linux system.
- **Configuration**: Ensure the `ansible.cfg` file is present to disable SSH host key checking.
- **Ansible Vault**: We are now using Ansible Vault for securing sensitive information.
  - Ensure the secrets file, vault password file, and `ansible.cfg` are present.
  - **Note**: The secrets file and vault password file are not uploaded to GitHub for security reasons.

# **Azure Deployment Steps**

## **1. Create an Application in Entra for Terraform**

- Navigate to the **Azure Portal** and create a new application in **Entra** (Azure Active Directory).
- Ensure you register the application correctly to be used by Terraform.

## **2. Assign Contributor Role to the Service Principal**

- Assign the **Service Principal** of your application to the **Contributor** role. This will grant Terraform the necessary permissions to manage resources in your subscription.

## **3. Update the `terraform.tfvars` File**

- Open the `terraform.tfvars` file.
- Update it with your **Azure account information** and **application details**:
  - **Client ID**
  - **Client Secret** (Note: This is the **VALUE** of the secret, not the secret ID)
  - **Tenant ID**
  - **Subscription ID**

## **4. Accept License Agreements Using Azure CLI**

- Use the following commands to accept the required Check Point license agreements:

    ```bash
    az login
    az vm image terms accept --urn checkpoint:check-point-cg-r8120:mgmt-byol:latest (Manager)
    az vm image terms accept --urn checkpoint:check-point-cg-r8120:sg-byol:latest   (Gateway)
    ```

## **5. Increase vCPU Quota**

Ensure your subscription has enough **vCPU quota** and **Public IP quota** for the deployment. To check your current vCPU quota, you can use the following Azure CLI command:

```bash
az vm list-usage --location <your-region> --output table
```
---

# Azure Check Point Deployment

This Terraform project deploys Check Point security management resources in Azure. It sets up virtual networks, Check Point management VMs, and optionally, Ubuntu "monster" VMs.

## Configuration

The deployment is configured using a `terraform.tfvars` file. Here's an explanation of the variables:
```hcl
| **Variable** | **Description** |
|--------------|-----------------|
| `resource_count`         | Number of VNets and subsequent resources to create              |
| `subscription_id`        | Your Azure subscription ID                                      |
| `client_id`              | Your Azure client ID                                            |
| `client_secret`          | Your Azure client secret                                        |
| `tenant_id`              | Your Azure tenant ID                                            |
| `vm_os_offer`            | The Check Point OS offer (e.g., `"check-point-cg-r8120"`)       |
| `vm_os_sku`              | The Check Point OS SKU (e.g., `"mgmt-byol"`)                    |
| `location`               | Azure region for resource deployment                            |
| `resource_group_name`    | Name of the resource group to create or use                     |
| `disk_size`              | Size of the disk for Check Point VMs in GB                      |
| `vm_size`                | Size of the VM for Check Point managers                         |
| `admin_username`         | Username for the admin account                                  |
| `admin_password`         | Password for the admin account (sensitive)                      |
| `ubuntu_monster_vm_size` | Size of the Ubuntu "monster" VMs                                |
```

## Usage

1. Clone this repository.
2. Copy the `terraform.tfvars.example` file to `terraform.tfvars`.
3. Edit `terraform.tfvars` and fill in your specific values.
4. Run `terraform init` to initialize the Terraform working directory.
5. Run `terraform plan` to see the planned changes.
6. Go up one directory and run the THE_CONTROLLER.py.

## Example Configuration

```python
resource_count      = "1"
subscription_id     = "<SUBSCRIPTION_ID>"
client_id           = "<CLIENT_ID>"
client_secret       = "<CLIENT_SECRET>"
tenant_id           = "<TENANT_ID>"
vm_os_offer         = "check-point-cg-r8120"
vm_os_sku           = "mgmt-byol"
location            = "EastUS"
resource_group_name = "FL-SE-AZURE-resources"
disk_size           = 100
vm_size             = "Standard_B2ms"
admin_username      = "cpuser"
admin_password      = "<ADMIN_PASSWORD>"
ubuntu_monster_vm_size = "Standard_D2s_v3"
```

## Notes

- Ensure you keep your `admin_password` secret and never commit it to version control.
- The `bootstrap_script` variable is optional. If you have a bootstrap script, you can uncomment and use this variable.

## Security Considerations

- Use environment variables or a secure secret management system for sensitive values like `client_secret` and `admin_password`.
- Ensure your Azure credentials have the minimum required permissions for this deployment.
- Regularly rotate your Azure credentials and VM passwords.

## Support

For any issues or questions, please open an issue in the GitHub repository. Note that some files in the /custom/ folder are custom and involve external services like Docker Hub and personal accounts. As such, users will need to set up their own Docker Hub accounts and configure other necessary tools independently, as these are not supported by the project.

## **Workflow**

<div align="center">
<img src="images/Lab_Diagram.jpg" alt="Screenshot" width="500">
</div>