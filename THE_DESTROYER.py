# Destroyer Script for the CPFL SE Team Lab Environment
# Travis Lockman / Antaeus
# Check Point SoFL SE
# Last updated February 2024
# O_o tHe pAcKeTs nEvEr LiE o_O #

import os
import time
from THE_CONTROLLER import CONTROLLER

# Destroy AZURE, comment this section out if you're not working with it.
os.chdir('./azure')
CONTROLLER().run_command(['terraform', 'destroy', '-auto-approve'])
time.sleep(60)
CONTROLLER().run_command(['terraform', 'refresh']) 
CONTROLLER().run_command(['terraform', 'destroy', '-auto-approve'])
os.chdir(os.path.join(os.getcwd(), os.pardir))