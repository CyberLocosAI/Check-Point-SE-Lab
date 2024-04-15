# Controller Class for the CPFL SE Team Lab Environment
# Travis Lockman / Antaeus
# Check Point SoFL SE
# Last updated February 2024
# O_o tHe pAcKeTs nEvEr LiE o_O #

# Need to pip install boto3, paramiko for aws

import subprocess
import os
# import boto3 for future use with AWS
import time
import json
import re


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
                
    def azure_create_ansible_hosts_file(self, json_output_file, hosts_file, ansible_user, tfvars_file):
        # Read the JSON output file
        with open(json_output_file, 'r') as file:
            data = json.load(file)
        # Extract Ubuntu Docker main public IPs
        ubuntu_ips = []
        ubuntu_docker_main_ips = data.get('ubuntu_docker_main_ips', {}).get('value', {})
        for key, ip_details in ubuntu_docker_main_ips.items():
            if "public_ip" in ip_details:
                ubuntu_ips.append(ip_details['public_ip'])
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
                
                # Assuming there is a corresponding ubuntu machine entry for each student
                ubuntu_private_ip = data['ubuntu_docker_main_ips']['value'].get(f'ubuntu-docker-main-{student_index + 1}', {}).get('private_ip', 'N/A')
                
                subnets = data['vpc_subnet_details']['value']['FL-SE-AZURE-vnet-1']['subnets']
                external_subnet = ', '.join(subnets['external'][0])
                internal_subnet = ', '.join(subnets['internal'][0])
                dmz_subnet = ', '.join(subnets['dmz'][0])

                # Append the formatted text for this student to the content string
                content += f"""
                            -----------------------------------------------
                            Student {student_name}
                            VDI Machine - {student_vdi_ip}
                            Ubuntu Machine - {ubuntu_private_ip}
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
    
    ## Terraform
    ct.run_command(['terraform', 'apply', '-auto-approve'])
    print(f'\n\nPausing for 3 minutes to allow for initalization...\n\n')
    time.sleep(180)
    ct.run_command(['terraform', 'refresh']) # Doing a refresh to grab proper outputs.
    ct.save_terraform_output()

    ## Ansible
    ct.azure_create_ansible_hosts_file(
                    json_output_file='tf_outputs.json',  # Path to the Terraform output JSON file
                    hosts_file='core_ubuntu_docker_machines.ini',  # Output Ansible hosts file
                    ansible_user='instructor',  # Username to login.
                    tfvars_file='terraform.tfvars'  # Terraform tfvars
                                            )
        ### Playbooks for Ubuntu Server
    ct.run_command(['ansible-playbook', '-i', 'core_ubuntu_docker_machines.ini', 'core_ansible_create_docker_backbone.yaml'])
    ct.run_command(['ansible-playbook', '-i', 'core_ubuntu_docker_machines.ini', 'whale_ansible_ubuntu_attack.yaml'])
    ct.run_command(['ansible-playbook', '-i', 'core_ubuntu_docker_machines.ini', 'whale_ansible_apache_vuln.yaml'])
    ct.run_command(['ansible-playbook', '-i', 'core_ubuntu_docker_machines.ini', 'whale_ansible_webgoat.yaml'])
    ct.run_command(['ansible-playbook', '-i', 'core_ubuntu_docker_machines.ini', 'whale_ansible_metasploitable.yaml'])
    ct.run_command(['ansible-playbook', '-i', 'core_ubuntu_docker_machines.ini', 'whale_ansible_ftp_server.yaml'])
    
        ### Playbooks for Check Point Manager

        ### Playbooks for Check Point Firewall
    
    ## Output Student Lab File
    ct.process_terraform_data('tf_outputs.json', 'STUDENT_LAB_INFO.txt')

    # This is the last command for AZURE, it exits the directory.
    os.chdir(os.path.join(os.getcwd(), os.pardir))