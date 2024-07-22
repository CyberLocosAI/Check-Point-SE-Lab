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

<div align="center">
<img src="images/Lab_Diagram.jpg" alt="Screenshot" width="300">
</div>

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
*core_ansible_create_docker_backbone* - Installs and configures Docker on student Ubuntu machines, plus other configurations.


*--Docker--*
We need to make our dockerhub public!


## **Prerequisites**

## **Environment Prep**

More to come



**Terraform Execution**

Inside the azure and/or aws folder:

`terraform init`

More to come...



## **How To Use This Lab**

More to come:

```python
python3 THE_CONTROLLER.py
```


## **Acknowledgements**

Kobe Bryant, and more to come.
But did you destroy....?