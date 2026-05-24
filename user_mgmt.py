#!/usr/bin/env python3
import argparse
import os
import sys
import subprocess
from datetime import datetime
import logging

LOG_FILE = "user_mgmt.log1"

# logging script
def log_action(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    logging.info(f"{timestamp} - {message}")

# check to see if user exists
def check_user_exists(username):
    try:
        subprocess.check_output(['id', username], stderr=subprocess.DEVNULL)
        return True
    except subprocess.CalledProcessError:
        return False

# create user with groups
def create_user(username, groups):
    if check_user_exists(username):
        print(f"User {username} already exists")
        return False

    try:
        if not check_privileges():
            print("Insufficient privileges to create groups")
            return False

        for group in groups:
            if not check_group_exists(group):
                subprocess.run(["groupadd", group], check=True)
                print(f"Created group: {group}")

        subprocess.run(["useradd", "-m", "-s", "/bin/bash", "-g", "users", "-G", ",".join(groups), "-p", "*", username], check=True)
        print(f"Created user: {username}")
        print(f"Groups: {', '.join(groups)}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to create user {username}: {e}")
        return False

# delete user and home directory
def delete_user(username):
    if not check_user_exists(username):
        print(f"User: {username} does not exist")
        log_action(f"Failed: User (username) does not exist")
        return False
    if input("Delete user {} and home directory? (y/N): ".format(username)).lower() != "y":
        print("Cancelled")
        return False
    
    os.system(f"userdel -r {username}")

    if os.path.isdir("/var/mail/{}".format(username)):
        os.system(f"rm -rf '/var/mail/{username}'")
        print(f"Deleted mail spool for user {username}")
    else:
        print(f"Mail spool for user {username} not found")
    
    log_action(f"Deleted user {username}")

# check groups for user
def check_groups(username):
    groups = os.popen("groups {}".format(username)).read().split('\n')
    print("Gropus for user {}: {}".format(username, ', '.join(groups)))

# check if group exists
def check_group_exists(group):
    try:
        subprocess.run(["groupadd", "--list"], check=True, capture_output=True, text=True, encoding="utf-8")
        output = subprocess.check_output(["grep", group, "/etc/group"], stderr=subprocess.DEVNULL)
        return bool(output)
    except subprocess.CalledProcessError:
        return False

# check permissions for user
def check_permissions(username, permission):
    if check_user_exists(username):
        try:
            subprocess.check_output(["sudo", "-u", username, "getent", "acl", '/'])
            print(f"User {username} has permission {permission}")
        except subprocess.CalledProcessError:
            print(f"User {username} does not have permission {permission}")
    else:
        print(f"User {username} does not exist")

# check if script is run with root privileges
def check_privileges():
    try:
        subprocess.run(["id", "-u"], check=True, capture_output=True, text=True, encoding="utf-8")
        uid = int(subprocess.check_output(["id", "-u"], stderr=subprocess.DEVNULL))
        return uid == 0
    except subprocess.CalledProcessError:
        return False

# main function to handle user input and call appropriate functions
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('username', help='Username to create')
    args = parser.parse_args()

    logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format='%(asctime)s - %(message)s')

    while True:
        print('Linux User Management Script')
        print('1. Create User')
        print('2. Delete User')
        print('3. Check Groups')
        print('4. Check Permissions')
        print('5. Check Privileges')
        print('5. Exit')

        choice = input('Enter your choice: ')

        if choice == '1':
            groups = input('Enter groups (comma separated): ').split(',')
            create_user(args.username, [group.strip() for group in groups])
        elif choice == '2':
            delete_user(args.username)
        elif choice == '3':
            check_groups(args.username)
        elif choice == '4':
            permission = input('Enter permission to check: ')
            check_permissions(args.username, permission)
        elif choice == '5':
            print('Exiting...')
            break
        else:
            print('Invalid choice. Please try again.')

if __name__ == '__main__':
    main()