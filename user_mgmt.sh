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

    if id "$username" >/dev/null 2>&1; then
        echo "User $username already exists"
        log_action "Failed: User $username already exists"
        return 1
    fi

    sudo useradd -m -s /bin/bash "$username"

    for group in "${groups[@]}"; do
        sudo groupadd -f "$group"
        sudo usermod -aG "$group" "$username"
    done

    echo "Created user: $username"
    echo "Groups: ${groups[*]}"

    log_action "Created user $username with groups: ${groups[*]}"
}
# function to delete a user
delete_user() {

    local username="$1"
    if ! id "$username" >/dev/null 2>&1; then 
        echo "User $username does not exist"
        log_action "Failed: User $username does not exist"
        return 1
    fi

    read -p "Delete user $username and home directory? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return 0
    fi

    sudo userdel -r "$username"
    echo "Deleted user: $username"

    # check if the user's mail spool directory exists and remove it if it does
    if [ -d "/var/mail/$username" ]; then
        sudo rm -rf "/var/mail/$username"
        echo "Deleted mail spool for user $username"
    else
        echo "Mail spool for user $username not found"
    fi

    log_action "Deleted user $username"
}

add_to_group() {
    local username="$1"
    local group ="$2"

    if ! id "$username" >/dev/null 2>&1; then
        echo "User $username does not exist"
        return 1
    fi

    sudo groupadd -f "$group"

    if groups "$username" | grep -qw "$group"; then
        echo "User $username is already in group $group"
        return 0
    fi

    sudo usermod -aG "$group" "$username"
    echo "Added $username to group: $group"
    log_action "Added $username to group: $group"
}

remove_from_group() {
    local username="$1"
    local group="$2"

    if ! id "$username" >/dev/null 2>&1; then
        echo "User $username does not exist"
        return 1
    fi

    if ! groups "$username" | grep -qw "$group"; then
        echo "User $username is not in group $group"
        return 1
    fi

    sudo gpasswd -d "$username" "$group"
    echo "Removed $username from group $group"
    log_action "Removed $username from group $group"
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

toggle_account() {
    local username="$1"
    local action="$2"

    if ! id "$username" >/dev/null 2>&1; then
        echo "User $username does not exist"
        return 1
    fi 

    if [[ "$action" == "lock" ]]; then
        sudo usermod -L "$username"
        echo "Locked user account: $username"
        log_action "Locked user account: $username"
    elif [[ "$action" == "unlock" ]]; then
        sudo usermod -U "$username"
        echo "Unlocked account: $username"
        log_action "Unlocked user account: $username"
    else
        echo "Invalid action: $action"
        return 1
    fi
}
list_users() {
    echo "System Users (UID >= 1000):"
    echo "----------------------------"
    awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd | while read -r user; do
        printf "%-15s %s\n" "$user" "$(groups "$user" | cut -d: -f2)"
    done
    log_action "Listed all users"
}

show_menu() {
    echo "Linux User Management Script"
    echo "1) Create User"
    echo "2) Delete User"
    echo "3) Add User to Group"
    echo "4) Remove User from Group"
    echo "5) Lock/Unlock Account"
    echo "6) Check User Groups"
    echo "7) List All Users"
    echo "8) View Log"
    echo "0) Exit"
}

# main menu for the user management script
main () {

    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root user"
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "Enter choice between 0-9: " choice
        echo ""

        case $choice in 
            1) 
                read -rp "Username: " username
                read -rp "Groups (space-separated): " groups
                create_user "$username" $groups
                ;;
            2)
                read -rp "Username: " username
                delete_user "$username"
                ;;
            3)
                read -rp "Username: " username
                read -rp "Group: " group
                add_to_group "$username" "$group"
                ;;
            4)
                read -rp "Username: " username
                read -rp "Group to remove: " group
                remove_from_group "$username" "$group"
                ;;
            5)
                read -rp "Username: " username
                read -rp "Action (lock/unlock): " action
                toggle_account "$username" "$action"
                ;;
            6)
                read -rp "Username: " username
                check_groups "$username"
                ;;
            7)
                list_users
                ;;
            8)
                if [[ -f "$LOG_FILE" ]]; then
                    echo "Last 20 log entries:"
                    echo "----------------------------"
                    tail -n 20 "$LOG_FILE"
                else
                    echo "❌ No log file found"
                fi
                ;;
            0)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "❌ Invalid option. Choose between 0-8"
                ;;
        esac

        read -rp "Press Enter to continue..."
    done
 }

main
