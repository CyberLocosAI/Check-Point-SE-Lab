usernames         = ["student1", "student2", "student3", "student4", "student5"]
passwords         = ["Cp53f1!1", "Cp53f1!2", "Cp53f1!3", "Cp53f1!4", "Cp53f1!5"]
admin_password   = "Cpm@st3r!"
client_id         = "018ab96b-8c4a-480c-96a3-9c78f7205809"
client_secret     = "u6a8Q~SMZyDGXnAQVGbXuD2Igmpmg0EGe2-X2bus"
tenant_id         = "2e1937a7-c5b3-4c7e-91fb-2d655a96e7d0"
subscription_id   = "d7594306-80ff-43af-8ec0-24c42434c159"
location          = "EastUS"
resource_group_name = "pub_IPs"
vm_size           = "Standard_B2s" # Adjust the VM size as needed
vm_os_publisher   = "Canonical" # Ubuntu's publisher
vm_os_offer       = "UbuntuServer" # The offer name for Ubuntu Server
vm_os_sku         = "18.04-LTS" # Specifies the Ubuntu version, adjust as needed (e.g., "20.04-LTS" for Ubuntu 20.04)
disk_size         = 30 # Adjust the OS disk size as needed


# Optionally, if you have a bootstrap script
# bootstrap_script = "your_encoded_bootstrap_script"
