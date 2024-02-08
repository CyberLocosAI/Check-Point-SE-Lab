# Controller Class for the CPFL SE Team Lab Environment
# Travis Lockman / Antaeus
# Check Point SoFL SE
# Last updated February 2024
# O_o tHe pAcKeTs nEvEr LiE o_O #

# Need to pip install boto3, paramiko

import subprocess
import os
import boto3
import time
import paramiko
import json
import re
from dotenv import load_dotenv


class CONTROLLER:
    def __init__(self):
        self.manager = 'More to come here'

    def run_command(self, command):
        """
        Run a given command on the system.
        :param command: A list representing the command to run and its arguments (e.g., ['ls', '-l'] on Linux or ['dir'] on Windows).
        """
        try:
            # Run the command
            subprocess.run(command, check=True, env=os.environ)
        except subprocess.CalledProcessError as e:
            # Handle errors in the subprocess
            print(f"Error running command {' '.join(command)}: {e}")
        except FileNotFoundError:
            # Handle the case where the command is not found
            print(f"Command not found: {' '.join(command)}")

    def run_command_remote_ssh(self, host, username, key_file, commands): # If you are chaining commands, seperate with ' && '
        key = paramiko.RSAKey.from_private_key_file(key_file)
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(hostname=host, username=username, pkey=key)
            stdin, stdout, stderr = client.exec_command(commands)
            output = stdout.read().decode()
            if output:
                print("Output:", output)
            error = stderr.read().decode()
            if error:
                print("Error:", error)
        finally:
            client.close()
    
    def save_terraform_output(self):
        command = "terraform output -json"
        output_file = "tf_outputs.json"
        try:
            output = subprocess.check_output(command, shell=True, text=True, env=os.environ)
            with open(output_file, "w") as file:
                file.write(output)
            print(f"Terraform outputs successfully written to {output_file}")
        except subprocess.CalledProcessError as e:
            print(f"An error occurred: {e}")

    def get_latest_ami_id(self, aws_product, key_id, secret, region, ami_name):
        """Fetch the latest AMI ID from AWS Marketplace."""
        ec2_client = boto3.client(aws_product, aws_access_key_id=key_id,
                                aws_secret_access_key=secret, region_name=region)
        # Filter AMIs
        # Adjust as needed
        filters = [{'Name': 'name', 'Values': [f'*{ami_name}*']}]
        response = ec2_client.describe_images(Filters=filters)
        print(response)
        images = response['Images']
        
        # Sort images by creation date and get the latest one
        if not images:
            raise ValueError("No AMIs found matching the filters")
        latest_image = max(images, key=lambda x: x['CreationDate'])
        return latest_image['ImageId']
    
    def update_env_file(self, env_file_name, key, value):
        # Read the existing content
        with open(env_file_name, 'r') as file:
            lines = file.readlines()

        # Modify the line
        updated_lines = []
        for line in lines:
            if line.startswith(key):
                updated_lines.append(f"{key}={value}\n")
            else:
                updated_lines.append(line)

        # Write the updated content
        with open(env_file_name, 'w') as file:
            file.writelines(updated_lines)

    def aws_create_ansible_hosts_file(self, json_output_file, hosts_file, 
                                            ssh_key_file, ansible_user):
        with open(json_output_file, 'r') as file:
            data = json.load(file)
        vpc_details = data['vpc_details']['value']
        ubuntu_ips = []
        for vpc_id, vpc_info in vpc_details.items():
            for subnet_info in vpc_info['external_subnets'].values():
                instance_ips = subnet_info.get('instances', [])
                ubuntu_ips.extend(instance_ips)
        with open(hosts_file, 'w') as file:
            file.write("[my_server_group]\n")
            for idx, ip in enumerate(ubuntu_ips):
                file.write(f"server{idx+1} ansible_host={ip} "
                            f"ansible_ssh_private_key_file={ssh_key_file} "
                            f"ansible_user={ansible_user}\n")
                
    def azure_create_ansible_hosts_file(self, json_output_file, hosts_file, ansible_user, tfvars_file):
        # Read the JSON output file
        with open(json_output_file, 'r') as file:
            data = json.load(file)
        # Extract Ubuntu Docker main public IPs
        ubuntu_ips = []
        if "ubuntu_docker_main_ips" in data and "value" in data["ubuntu_docker_main_ips"]:
            for key, ip in data["ubuntu_docker_main_ips"]["value"].items():
                if "ubuntu-docker-main" in key:
                    ubuntu_ips.append(ip)
        # Read the tfvars file to get the admin_password
        admin_password = None
        with open(tfvars_file, 'r') as file:
            for line in file:
                # Check if line contains the admin_password variable
                match = re.match(r'^admin_password\s*=\s*"(.*)"$', line)
                if match:
                    admin_password = match.group(1)
                    break
        # Exit if admin_password is not found
        if admin_password is None:
            print("admin_password not found in tfvars file.")
            return
        # Write to the hosts file
        with open(hosts_file, 'w') as file:
            file.write("[ubuntu_docker_main_machines]\n")
            for idx, ip in enumerate(ubuntu_ips):
                file.write(f"server{idx+1} ansible_host={ip} "
                        f"ansible_user={ansible_user} "
                        f"ansible_ssh_pass={admin_password}\n")
    
    def print_vpc_details_to_file(self, json_output_file, output_text_file):
        # Load the JSON data from the Terraform output
        with open(json_output_file, 'r') as file:
            data = json.load(file)['vpc_details']['value']

        with open(output_text_file, 'w') as file:
            for vpc_id, vpc_info in data.items():
                file.write(f"VPC ID: {vpc_id}\n")
                file.write(f"CIDR Block: {vpc_info['cidr_block']}\n")
                file.write(f"DNS Hostnames: {vpc_info['dns_hostnames']}\n")
                file.write(f"DNS Support: {vpc_info['dns_support']}\n")
                file.write(f"Internet Gateway: {vpc_info['internet_gateway']}\n")

                # Subnets
                if 'external_subnets' in vpc_info:
                    file.write("\nExternal Subnets:\n")
                    for subnet_id, subnet_info in vpc_info['external_subnets'].items():
                        file.write(f"  Subnet ID: {subnet_id}\n")
                        file.write(f"  CIDR Block: {subnet_info['cidr_block']}\n")
                        if 'instances' in subnet_info:
                            file.write("  Instances:\n")
                            for ip in subnet_info['instances']:
                                file.write(f"    IP: {ip}\n")

                if 'internal_subnet' in vpc_info:
                    file.write("\nInternal Subnets:\n")
                    file.write(f"  Subnet ID: {vpc_info['internal_subnet']['id']}\n")
                    file.write(f"  CIDR Block: {vpc_info['internal_subnet']['cidr_block']}\n")

                if 'dmz_subnet' in vpc_info:
                    file.write("\nDMZ Subnets:\n")
                    file.write(f"  Subnet ID: {vpc_info['dmz_subnet']['id']}\n")
                    file.write(f"  CIDR Block: {vpc_info['dmz_subnet']['cidr_block']}\n")

                file.write("\n--------------------------------------------------\n")


if __name__ == '__main__':

    # Instatiating the controller constructor
    ct = CONTROLLER()
    
    ###########
    ### AWS ###
    ##############################################################################################
    # os.chdir('./aws')
    # load_dotenv('.env')

    ### Terraform
    # This command executes any .tf files in the same directory, be careful!
    # ct.run_command(['terraform', 'apply', '-auto-approve'])
    # ct.save_terraform_output()
    # ct.print_vpc_details_to_file('tf_outputs.json', 'full_lab_info_aws.txt')
    
    ### Ansible
    # ct.create_ansible_hosts_file_for_ubuntu(
    #                 json_output_file='tf_outputs.json',  # Path to the Terraform output JSON file
    #                 hosts_file='hosts.ini',  # Output Ansible hosts file
    #                 ssh_key_file='fllabmainkey.pem',  # Path to your SSH private key
    #                 ansible_user='ubuntu'  # Ansible username
    #                                         )
    # print(f'\n\nPausing for 5 minutes to allow for initalization...\n\n')
    # time.sleep(300)
    # ct.run_command(['ansible-playbook', '-i', 'hosts.ini', 'install_docker.yaml'])
    
    # This is the last command for AWS, it exits the directory.
    #os.chdir(os.path.join(os.getcwd(), os.pardir))

    #############
    ### AZURE ###
    ##############################################################################################
    # Telling Python to enter the azure directory
    os.chdir('./azure')
    
    # ### Terraform
    # ct.run_command(['terraform', 'apply', '-auto-approve'])
    # print(f'\n\nPausing for 5 minutes to allow for initalization...\n\n')
    # time.sleep(300)
    ct.run_command(['terraform', 'refresh']) # Doing a refresh to grab proper outputs.
    ct.save_terraform_output()

    ## Ansible
    ct.azure_create_ansible_hosts_file(
                    json_output_file='tf_outputs.json',  # Path to the Terraform output JSON file
                    hosts_file='core_ubuntu_docker_machines.ini',  # Output Ansible hosts file
                    ansible_user='instructor',  # Username to login.
                    tfvars_file='terraform.tfvars'  # Terraform tfvars
                                            )
    ct.run_command(['ansible-playbook', '-i', 'core_ubuntu_docker_machines.ini', 'core_ansible_install_docker.yaml'])
    
    # This is the last command for AZURE, it exits the directory.
    os.chdir(os.path.join(os.getcwd(), os.pardir))