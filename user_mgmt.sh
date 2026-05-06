#!/bin/bash

# log file for user management actions
LOG_FILE="./user_mgmt.log"

# updates the log with the timestamp of the action performed
log_action() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $1" >> "$LOG_FILE"
}

# creates a user with the input username and group
create_user() {
    local username="$1"
    local groups=("${@:2}")

    # checks to see if the user already exists, it so it will say it does
    if sudo id -u "$username" >/dev/null 2>&1; then
        log_action "User $username already exists"
        return
    fi

    # creates the username
    sudo useradd -m -s /bin/bash "$username"

    # adds the groups
    for group in "${groups[@]}"; do
        sudo groupadd -f "$group"
        sudo usermod -aG "$group" "$username"
    done

    log_action "Created user $username with groups: ${groups[*]}"
}

# function to delete a user
delete_user() {
    local username="$1"
    # checks to see if the user exists
    if sudo id -u "$username" >/dev/null 2>&1; then
        sudo userdel -r "$username"
        # prints deleted the user if it exists, otherwise bottom says does not exist
        log_action "Deleted user $username"
    else
        log_action "User $username does not exist"
    fi
}

# function to check if the user has the specificed permisssion
check_permissions() {
    local username="$1"
    local permission="$2"

    # checks to see if the user has the permission, if so it will say, if not it will say they don't
    if sudo id -nG "$username" | grep -q "\b$permission\b"; then
        log_action "User $username has permission $permission"
    else
        log_action "User $username does not have permission $permission"
    fi
}

# function to check if the user in the group
check_groups() {
    local username="$1"
    local group="$2"

    # checks to see if the user in the group
    # if so it will say in the group, if not it will say not in the group
    if sudo groups "$username" | grep -q "\b$group\b"; then
        log_action "User $username is in group $group"
    else
        log_action "User $username is not in group $group"
    fi
}

# main menu for the user management script
main () {
    while true; do
        echo "Linux/Bash Automated Group Management Script"
        echo "1. Create User"
        echo "2. Delete User"
        echo "3. Check permissions"
        echo "4. Check groups"
        echo "5. Exit"
        echo "Choose option [1-5]: "
        read -r choice

        case $choice in 
            1|create)
                read -p "Enter Username: " username
                read -p "Enter groups: " group_input

                IFS=', ' read -r -a groups <<< "$group_input"
                create_user "$username" "${groups[@]}"
                ;;
            2|delete)
                read -p "Enter usename: " username
                delete_user "$username"
                ;;
            3|check_permissions)
                read -p "Enter username: " username
                read -p "Enter permission to check: " permission
                check_permissions "$username" "$permission"
                ;;
            4|check_groups)
                read -p "Enter username: " username
                read -p "Enter group to check: " group
                check_groups "$username" "$group"
                ;;
            5|exit)
                echo "Exiting"
                break
                ;;
            *)
                echo "Invalid option, Please enter 1-5"
                ;;
        esac
    done
 }

main
