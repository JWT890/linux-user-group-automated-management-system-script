# linux-user-group-automated-management-system-script

Linux User & Group Automated Management System  
A dual-implementation toolkit for automating Linux user and group administration. The project provides both an interactive Bash shell script (user_mgmt.sh) and a Python CLI (user_mgmt.py) to manage system users and groups, with all actions logged to file for auditing.  

# Features

Create users with a home directory, default shell, and one or more groups in a single command  
Delete users and automatically clean up their home directory and mail spool  
Add or remove users from groups  
Lock and unlock user accounts  
Change user and group passwords  
List all system users (UID ≥ 1000) along with their group memberships  
List all groups on the system  
Check whether a user belongs to a given group  
Check user permissions  
Timestamped audit log of every action performed (user_mgmt.log / user_mgmt.log1)  


Files  
FileDescriptionuser_mgmt.shInteractive Bash script with a numbered menu (315 lines)user_mgmt.pyPython 3 CLI with argparse and a numbered menu (138 lines)users.csvSample CSV file for reference user datauser_mgmt.logAudit log produced by the Bash scriptuser_mgmt.log1Audit log produced by the Python script  

Requirements  
Bash script (user_mgmt.sh)  

Bash 4+  
Standard Linux utilities: useradd, userdel, groupadd, gpasswd, usermod, passwd, getent  
Must be run as root (the script enforces this on startup)  

Python script (user_mgmt.py)  

Python 3.6+  
No third-party packages — uses only the standard library (subprocess, argparse, os, logging)  
Must be run as root  


# Usage
Bash Script  
bashsudo bash user_mgmt.sh  
You will be presented with an interactive menu:  
Linux User Management Script  
1) Create User  
2) Delete User  
3) Add User to Group  
4) Remove User from Group  
5) Lock/Unlock Account  
6) Check User Groups  
7) List Groups  
8) View Log  
0) Exit  
Python Script  
bashsudo python3 user_mgmt.py <username>  
The username is passed as a positional argument and used for all operations in that session. An interactive menu is then displayed:  
1. Create User  
2. Delete User  
3. Check Groups  
4. Check Permissions  
5. Exit  

Logging  
All operations are appended to a log file with a timestamp:  
2025-03-01 14:22:05 - Created user jsmith with groups: developers sudo  
2025-03-01 14:23:10 - Added jsmith to group: docker  
2025-03-01 14:25:44 - Locked user account: jsmith  

Bash script logs to ./user_mgmt.log  
Python script logs to ./user_mgmt.log1  


Example Workflow (Bash)  
bash# Run as root  
sudo bash user_mgmt.sh  

Select option 1 to create a user  
Username: jsmith  
Groups: developers sudo  

Select option 3 to add the user to an additional group  
Username: jsmith  
Group: docker  

Select option 5 to lock the account
Username: jsmith  
Action: lock  

Security Notes

Both scripts require root privileges and will exit or refuse to operate without them.  
The Bash delete_user function prompts for confirmation before removing a user and their home directory.  
The Python delete_user function similarly prompts before deletion.  
Passwords are set interactively via passwd (Bash) — no plaintext passwords are stored.  
