# Controller Class for the CPFL SE Team Lab Environment
# Travis Lockman / Antaeus
# Check Point SoFL SE
# Last updated February 2024
# O_o tHe pAcKeTs nEvEr LiE o_O #

# Need to pip install boto3, paramiko for aws

import subprocess
import os
import time
import json
import re
# import boto3 #Enable for AWS


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
                
    def azure_create_ansible_hosts_file(self, json_output_file, hosts_file, ubuntu_ansible_user, cp_ansible_user, tfvars_file):
        # Read the JSON output file
        with open(json_output_file, 'r') as file:
            data = json.load(file)
            
        # Extract Ubuntu Docker main public IPs
        ubuntu_ips = []
        ubuntu_docker_main_ips = data.get('ubuntu_docker_main_ips', {}).get('value', {})
        for key, ip_details in ubuntu_docker_main_ips.items():
            if "public_ip" in ip_details:
                ubuntu_ips.append(ip_details['public_ip'])
                
        # Extract Checkpoint Firewall public IPs
        checkpoint_fw_ips = data.get('checkpoint_gateway_details', {}).get('value', {}).get('public_ips', [])
        
        # Extract Checkpoint Management public IPs
        checkpoint_mgmt_ips = data.get('checkpoint_mgmt_details', {}).get('value', {}).get('public_ip_addresses', [])
        
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
            # Ubuntu Docker Main Machines Section
            file.write("[ubuntu_docker_main_machines]\n")
            for idx, ip in enumerate(ubuntu_ips):
                file.write(f"server{idx+1} ansible_host={ip} "
                           f"ansible_user={ubuntu_ansible_user} "
                           f"ansible_ssh_pass={admin_password}\n")
                
            # Checkpoint Firewall Section
            file.write("\n[checkpoint_gateway_details]\n")
            for idx, ip in enumerate(checkpoint_fw_ips):
                file.write(f"fw{idx+1} ansible_host={ip} "
                           f"ansible_user={cp_ansible_user} "
                           f"ansible_ssh_pass={admin_password}\n")
                
            # Checkpoint Management Section
            file.write("\n[checkpoint_mgmt_details]\n")
            for idx, ip in enumerate(checkpoint_mgmt_ips):
                file.write(f"mgmt{idx+1} ansible_host={ip} "
                           f"ansible_user={cp_ansible_user} "
                           f"ansible_ssh_pass={admin_password}\n")
    
    def azure_create_ansible_hosts_file(self, json_output_file, hosts_file, ubuntu_ansible_user, cp_ansible_user, tfvars_file):
        # Read the JSON output file
        with open(json_output_file, 'r') as file:
            data = json.load(file)
            
        # Extract Ubuntu Docker main public IPs
        ubuntu_ips = []
        ubuntu_docker_main_ips = data.get('ubuntu_docker_main_ips', {}).get('value', {})
        for key, ip_details in ubuntu_docker_main_ips.items():
            if "public_ip" in ip_details:
                ubuntu_ips.append(ip_details['public_ip'])
                
        # Extract Checkpoint Firewall public IPs
        checkpoint_fw_ips = data.get('checkpoint_gateway_details', {}).get('value', {}).get('public_ips', [])
        
        # Extract Checkpoint Management public IPs
        checkpoint_mgmt_ips = data.get('checkpoint_mgmt_details', {}).get('value', {}).get('public_ip_addresses', [])
        
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
            # Ubuntu Docker Main Machines Section
            file.write("[ubuntu_docker_main_machines]\n")
            for idx, ip in enumerate(ubuntu_ips):
                file.write(f"server{idx+1} ansible_host={ip} "
                           f"ansible_user={ubuntu_ansible_user} "
                           f"ansible_ssh_pass={admin_password}\n")
                
            # Checkpoint Firewall Section
            file.write("\n[checkpoint_gateway_details]\n")
            for idx, ip in enumerate(checkpoint_fw_ips):
                file.write(f"fw{idx+1} ansible_host={ip} "
                           f"ansible_user={cp_ansible_user} "
                           f"ansible_ssh_pass={admin_password}\n")
                
            # Checkpoint Management Section
            file.write("\n[checkpoint_mgmt_details]\n")
            for idx, ip in enumerate(checkpoint_mgmt_ips):
                file.write(f"mgmt{idx+1} ansible_host={ip} "
                           f"ansible_user={cp_ansible_user} "
                           f"ansible_ssh_pass={admin_password}\n")
    
    def process_terraform_data(self, filename, output_filename):
        with open(filename, 'r') as file:
            data = json.load(file)

        # NATO phonetic alphabet (covers up to 78 students)
        phonetic_alphabet = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel",
                            "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa",
                            "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey",
                            "X-ray", "Yankee", "Zulu", "Antonio", "Barcelona", "Carmen", "Domingo", "Enrique", "Francia",
                            "Granada", "Historia", "Inés", "José", "Kilo", "Lorenzo",
                            "Madrid", "Navidad", "Ñoño", "Otoño", "París", "Querétaro",
                            "Ramón", "Santiago", "Teresa", "Ulises", "Valencia", "Washington",
                            "Xilófono", "Yolanda", "Zaragoza", "Anatole", "Berthe", "Célestin", "Désiré", "Eugène", "François",
                            "Gaston", "Henri", "Irma", "Joseph", "Kléber", "Louis",
                            "Marcel", "Nicolas", "Oscar", "Pierre", "Quentin", "Raoul",
                            "Suzanne", "Thérèse", "Ursule", "Victor", "William", "Xavier",
                            "Yvonne", "Zoé"]

        content = ""

        # Loop through the student VDI details
        for key, student in data['student_vdi_details']['value'].items():
            if key.startswith('student-vdi-'):
                # Extract the student number from the key and convert it to an index
                student_index = int(key.split('-')[-1]) - 1  # assuming student-vdi-1 corresponds to index 0

                # Use the phonetic alphabet for naming, default to numeric if out of range
                student_name = phonetic_alphabet[student_index] if student_index < len(phonetic_alphabet) else f"Student {student_index + 1}"

                student_vdi_ip = student['Public_IP']

                # Fetch Ubuntu machine details
                ubuntu_private_ip = data['ubuntu_docker_main_ips']['value'].get(f'ubuntu-docker-main-{student_index + 1}', {}).get('private_ip', 'N/A')

                # Fetch CP Manager and CP Gateway details for each student if they exist
                cp_manager_public_ip = data['checkpoint_mgmt_details']['value']['public_ip_addresses'][student_index] if student_index < len(data['checkpoint_mgmt_details']['value']['public_ip_addresses']) else 'N/A'
                cp_manager_private_ip = data['checkpoint_mgmt_details']['value']['private_ip_addresses'][student_index] if student_index < len(data['checkpoint_mgmt_details']['value']['private_ip_addresses']) else 'N/A'

                cp_gateway_public_ip = data['checkpoint_gateway_details']['value']['public_ips'][student_index] if student_index < len(data['checkpoint_gateway_details']['value']['public_ips']) else 'N/A'
                cp_gateway_private_ip = data['checkpoint_gateway_details']['value']['private_ips'][student_index] if student_index < len(data['checkpoint_gateway_details']['value']['private_ips']) else 'N/A'

                # Fetch subnet details specific to each student
                subnets = data['vpc_subnet_details']['value'].get(f'FL-SE-AZURE-vnet-{student_index + 1}', {}).get('subnets', {})
                external_subnet = ', '.join(subnets.get('external', [['N/A']])[0])
                internal_subnet = ', '.join(subnets.get('internal', [['N/A']])[0])
                dmz_subnet = ', '.join(subnets.get('dmz', [['N/A']])[0])

                # Append the formatted text for this student to the content string
                content += f"""
                            -----------------------------------------------
                            Student {student_name}
                            VDI Machine - {student_vdi_ip}
                            Ubuntu Machine - {ubuntu_private_ip}
                            CP Manager Public IP - {cp_manager_public_ip}
                            CP Manager Private IP - {cp_manager_private_ip}
                            CP Gateway Public IP - {cp_gateway_public_ip}
                            CP Gateway Private IP - {cp_gateway_private_ip}
                            External Subnet - {external_subnet}
                            Internal Subnet - {internal_subnet}
                            DMZ Subnet - {dmz_subnet}
                            -----------------------------------------------
                            """

        # Write to the output file
        with open(output_filename, 'w') as output_file:
            output_file.write(content)


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
    
    ### Ansible
    
    # This is the last command for AWS, it exits the directory.
    #os.chdir(os.path.join(os.getcwd(), os.pardir))

    #############
    ### AZURE ###
    ##############################################################################################
    # Telling Python to enter the azure directory
    os.chdir('./azure')

    # Check if 'custom_copied.txt' exists
    if not os.path.exists('custom_copied.txt'):
        # Copy the contents of the 'custom' folder into the 'azure' directory using Linux commands
        ct.run_command(['cp', '-r', '../custom/.', './'])
        # Create 'custom_copied.txt' to mark that the custom folder has been copied
        with open('custom_copied.txt', 'w') as f:
            f.write('Custom folder contents copied.')

    ## Terraform
    ct.run_command(['terraform', 'apply', '-auto-approve'])
    print(f'\n\nPausing for 3 minutes to allow for initalization...\n\n')
    time.sleep(180)
    ct.run_command(['terraform', 'refresh']) # Doing a refresh to grab proper outputs.
    ct.save_terraform_output()

    ## Ansible
    ct.azure_create_ansible_hosts_file(
                    json_output_file='tf_outputs.json',  # Path to the Terraform output JSON file
                    hosts_file='core_machines.ini',  # Output Ansible hosts file
                    ubuntu_ansible_user='instructor',  # Username to login for ubuntu.
                    cp_ansible_user='admin', # Username to login for ubuntu.
                    tfvars_file='terraform.tfvars'  # Terraform tfvars
                                            )
        ### Playbooks for Ubuntu Server
    ct.run_command(['ansible-playbook', '-i', 'core_machines.ini', 'core_ansible_create_docker_backbone.yaml'])
    
        ### Playbooks for Check Point Manager

        ### Playbooks for Check Point Firewall

        ### Playbooks for WHALE
    # ct.run_command(['ansible-playbook', '-i', 'core_machines.ini', 'whale_ansible_ubuntu_attack.yaml'])
    # ct.run_command(['ansible-playbook', '-i', 'core_machines.ini', 'whale_ansible_apache_vuln.yaml'])
    # ct.run_command(['ansible-playbook', '-i', 'core_machines.ini', 'whale_ansible_webgoat.yaml'])
    # ct.run_command(['ansible-playbook', '-i', 'core_machines.ini', 'whale_ansible_metasploitable.yaml'])
    # ct.run_command(['ansible-playbook', '-i', 'core_machines.ini', 'whale_ansible_ftp_server.yaml'])
    
    ## Output Student Lab File
    ct.process_terraform_data('tf_outputs.json', 'STUDENT_LAB_INFO.txt')

    # This is the last command for AZURE, it exits the directory.
    os.chdir(os.path.join(os.getcwd(), os.pardir))