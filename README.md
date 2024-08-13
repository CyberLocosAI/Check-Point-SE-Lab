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

## Prerequisites

Ensure that you have the following installed on your Linux machine:

- Python
- Terraform
- Ansible
- Docker

## Getting Started

1. Clone the repository to your local machine.
2. Rename `terraform.tfvars.example` to `terraform.tfvars` and customize it with your environment details.
3. Run `THE_CONTROLLER.py` to start the lab environment setup.
4. Once you are done, execute `THE_DESTROYER.py` to clean up all resources.


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

- Use the following commands to accept the required license agreements:

    ```bash
    az login
    az vm image terms accept --urn checkpoint:check-point-cg-r8120:mgmt-byol:latest
    az vm image terms accept --urn checkpoint:check-point-cg-r8120:sg-byol:latest
    ```

## **5. Increase vCPU Quota**

- Ensure your subscription has enough **vCPU quota** for the deployment. If necessary, request an increase via the Azure Portal.

## **6. Increase Public IP Quota**

- Similarly, check and increase the **Public IP quota** to meet the deployment requirements.

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
6. Run `terraform apply` to create the resources.

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

For any issues or questions, please open an issue in the GitHub repository.

## **Workflow**

<div align="center">
<img src="images/Lab_Diagram.jpg" alt="Screenshot" width="500">
</div>


## **Prerequisites**

### Azure ###

1. Create an application for terraform in Entra.
2. Assign the service principal of your application to the contributor role.

3. Update the tfvars file with your account info and application info. 
Please note the client secret is the VALUE of the secret 
not the id of the secret.

4. Accept license agreements using azure cli with these commands
-az login
-az vm image terms accept --urn checkpoint:check-point-cg-r8120:mgmt-byol:latest
-az vm image terms accept --urn checkpoint:check-point-cg-r8120:sg-byol:latest

5. Increase vCPU quota. (Need to be off trial)

6. Increase public IP quota. (Need to be off trial)



## **Environment Prep**

### LINUX IS REQUIRED ###
-Ubuntu is preferred, update first.
-install terraform
-install ansible
-install sshpass

# Ansible Prep
-You will need to install sshpass on the system running ansible when using username and password on the linux system.
-Make sure the ansible cfg file is present to disable ssh host checking
-We are now using ansible vault, the secret file, vault password file, and ansible.cfg have to be present.
-the secrets file and vault pass file are not uploaded to GH for security.

## **Deployment Checklist**

1. Create an application for terraform in Entra.
2. Assign the service principal of your application to the contributor role.

3. Update the tfvars file with your account info and application info. 
Please note the client secret is the VALUE of the secret 
not the id of the secret.

4. Accept license agreements using azure cli with these commands
-az login
-az vm image terms accept --urn checkpoint:check-point-cg-r8120:mgmt-byol:latest
-az vm image terms accept --urn checkpoint:check-point-cg-r8120:sg-byol:latest

5. Increase vCPU quota. (Need to be off trial)

6. Increase public IP quota. (Need to be off trial)


**Terraform Execution**

Inside the azure and/or aws folder:

`terraform init`

More to come...

## **Acknowledgements**

Kobe Bryant, and more to come.
But did you destroy....?