#!/bin/bash

# creates the log file
LOG_FILE="./user_mgmt.log"

# showcases the date and timestamp
log_action() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $1" >> "$LOG_FILE"
}

# creates the user
create_user() {
    local username="$1"
    local groups=("${@:2}")
    
    # checks if the user already exists
    if sudo id -u "$username" >/dev/null 2>&1; then
        log_action "User $username already exists"
        return
    fi
    
    # creates the user
    sudo useradd -m -s /bin/bash "$username"
    
    # adds the groups
    for group in "${groups[@]}"; do
        sudo groupadd -f "$group" 2>/dev/null
        sudo usermod -aG "$group" "$username"
    done
    
    # sets the permissions
    log_action "Created user $username with groups ${groups[*]}"
}

# deletes the user
delete_user() {
    local username="$1"
    
    # checks if the user exists
    if sudo id -u "$username" >/dev/null 2>&1; then
        sudo userdel -r "$username"
        log_action "Deleted user $username"
    else
        # user does not exist
        log_action "User $username does not exist"
    fi
}

# checks the permissions
check_permissions() {
    local username="$1"
    local permission="$2"
    
    # checks if the user has the permission
    if sudo id -nG "$username" | grep -q "^$permission\b"; then
        log_action "User $username has $permission"
    else
        # user does not have the permission
        log_action "User $username does not have $permission"
    fi
}

# checks the groups
check_groups() {
    local username="$1"
    local group="$2"
    
    # checks if the user is in the group
    if sudo groups "$username" | grep -q "^$group\b"; then
        log_action "User $username is in group $group"
    else
        log_action "User $username is not in group $group"
    fi
}

case "$1" in
    create)
        create_user "$2" "${@:3}"
        ;;
    delete)
        delete_user "$2"
        ;;
    *)
        echo "Usage: $0 {create|delete} username [group1,group2]"
        ;;
esac
