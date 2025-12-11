#!/bin/bash

LOG_FILE="./user_mgmt.log"

log_action() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $1" >> "$LOG_FILE"
}

create_user() {
    local username="$1"
    local groups=("${@:2}")

    if sudo id -u "$username" >/dev/null 2>&1; then
        log_action "User $username already exists"
        return
    fi

    sudo useradd -m -s /bin/bash "$username"

    for group in "${groups[@]}"; do
        sudo groupadd -f "$group"
        sudo usermod -aG "$group" "$username"
    done

    log_action "Created user $username with groups: ${groups[*]}"
}

delete_user() {
    local username="$1"

    if sudo id -u "$username" >/dev/null 2>&1; then
        sudo userdel -r "$username"
        log_action "Deleted user $username"
    else
        log_action "User $username does not exist"
    fi
}

check_permissions() {
    local username="$1"
    local permission="$2"

    if sudo id -nG "$username" | grep -q "\b$permission\b"; then
        log_action "User $username has permission $permission"
    else
        log_action "User $username does not have permission $permission"
    fi
}

check_groups() {
    local username="$1"
    local group="$2"

    if sudo groups "$username" | grep -q "\b$group\b"; then
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
    permissions)
        check_permissions "$2" "$3"
        ;;
    groups)
        check_groups "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {create|delete|permissions|groups} username [groups...]"
        ;;
esac
