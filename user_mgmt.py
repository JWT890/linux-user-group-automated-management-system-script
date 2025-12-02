#!/usr/bin/env python3

import os
import sys
import subprocess
from datetime import datetime

LOG_FILE = "user_mgmt.log"

def log_action():
    with open(LOG_FILE, "w") as f:
	f.write(f"{datetime.now()} - {action]\n')

def create_user():
    subprocess.run(['sudo', 'useradd', "-m", "-s", "/bin/bash", username])
    for group in groups.split(",");
	subprocess.run(["sudo", "groupadd", "-f", group)]
	subprocess.run(["sudo", "usermod", "-aG", group, username])
    os.chmod(f"/home/{username}", 0o700)
    log_action(f"Created user {username} with groups {groups}")

def delete_user():

if __name__="__main__":

