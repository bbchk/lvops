#!/bin/bash

# I would like to enter my master password one time and that's all. 
# Should I clone my repo, decypher it, read that file with secret here? yeah!

# Exit immediately if a command exits with a non-zero status
set -e

# --- Root Password Change ---
echo -n "Enter new password for ROOT: "
stty -echo
read ROOT_PASSWORD
stty echo
echo
echo "root:$ROOT_PASSWORD" | /usr/sbin/chpasswd
echo "Root password updated successfully."

# --- Standard User Password Change ---
read -p "Enter username: " USERNAME
echo -n "Enter new password for $USERNAME: "
stty -echo
read NEW_PASSWORD
stty echo
echo
echo "$USERNAME:$NEW_PASSWORD" | /usr/sbin/chpasswd
echo "User $USERNAME password updated successfully."

# --- Change Hostname ---
read -p "Enter new hostname: " NEW_HOSTNAME
hostnamectl set-hostname "$NEW_HOSTNAME"
# Updates the hosts file to prevent "unable to resolve host" sudo errors
sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts
echo "Hostname changed to $NEW_HOSTNAME."

# --- Tailscale ---
read -p "Enter Tailscale auth key: " TS_AUTH_KEY
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey="$TS_AUTH_KEY" --accept-routes

echo "Setup complete!"
