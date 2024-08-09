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

## **Content**
The lab is created with Python, Terraform, Ansible, Docker.
It is built to execute from any linux platform, into Azure.

*--Python--*

*THE_CONTROLLER.py* - Oversees the running of all code, executes and processes output across the platform.
*THE_DESTROYER.py* - When finished, tears down all resources built for the lab.

*--Terraform--*

*terraform.tfvars.example* - Remove the .example to have a properly formatted variable file for Terraform.
*core_azure_backbone.tf* - Creates the backbone network for each student, 1 VNet with three subnets (internal, external, and DMZ)
*core_azure_student_VDIs.tf* - Creates one Windows VDI per student, with pre-configured software.
*core_azure_ubuntu_docker_main.tf* - Creates one Ubuntu server per student.
*core_azure_cpmanager.tf* - Creates one Check Point Manager per student.
*core_azure_cpgw01.tf* - Creates one Check Point Gateway per student.

*--Ansible--*

*ansible.cfg* - Configures key options to get Ansible running to deploy the lab.
*core_ansible_create_docker_backbone.yaml* - Installs and configures Docker on student Ubuntu machines, plus other configurations.

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


code area?:

```python
python3 THE_CONTROLLER.py
```


**Terraform Execution**

Inside the azure and/or aws folder:

`terraform init`

More to come...

## **Acknowledgements**

Kobe Bryant, and more to come.
But did you destroy....?