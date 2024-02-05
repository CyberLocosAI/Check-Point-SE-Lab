# Destroyer Script for the CPFL SE Team Lab Environment
# Travis Lockman / Antaeus
# Check Point SoFL SE
# Last updated February 2024
# O_o tHe pAcKeTs nEvEr LiE o_O #

import os
from THE_CONTROLLER import CONTROLLER
from dotenv import load_dotenv

# Destroy AWS, comment this section out if you're not working with it.
# os.chdir('./aws')
# load_dotenv('.env', override=True)
# CONTROLLER().run_command(['terraform', 'destroy', '-auto-approve'])
# os.chdir(os.path.join(os.getcwd(), os.pardir))

# Destroy AZURE, comment this section out if you're not working with it.
os.chdir('./azure')
#load_dotenv('.env', override=True) If you want to use .env uncomment
CONTROLLER().run_command(['terraform', 'destroy', '-auto-approve'])
os.chdir(os.path.join(os.getcwd(), os.pardir))