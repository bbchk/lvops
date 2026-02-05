#!/bin/bash

/usr/bin/apt-get update
/usr/bin/apt-get install -y sudo vim net-tools openssh-server ifupdown curl wget rsync

update-alternatives --set editor /usr/bin/vim.basic
#sudo systemctl disable nftables --now

# TODO tailscale
curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --auth-key=tskey-auth-k12Nr8Dw3z11CNTRL-TCcYpmmXBqNdCqS3emzzqN14pgk7QMB8

# The industry standard is to avoid editing the main /etc/sudoers file directly. Instead, you should drop a configuration file into the /etc/sudoers.d/ directory. It’s cleaner, modular, and much harder to break.
# echo "%sudo ALL=(ALL:ALL) ALL" | sudo tee /etc/sudoers.d/nopasswd_sudo
# gpasswd -a bchk sudo

curl -sfL https://get.k3s.io | sh -

mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config
export KUBECONFIG=$HOME/.kube/config
kubectl get nodes



# sudo systemctl edit k3s.service
# [Service]
# ExecStart=
# ExecStart=/usr/local/bin/k3s server --data-dir /home/k3s-data



# ---------

SSH_CONFIG="/etc/ssh/sshd_config"

sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' "$SSH_CONFIG"
sed -i 's/KerberosAuthentication yes/KerberosAuthentication no/' "$SSH_CONFIG"

systemctl restart sshd

# ---------

logind_conf="/etc/systemd/logind.conf"
sed -i 's/#HandlePowerKey=poweroff/HandlePowerKey=ignore/' "$logind_conf"
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' "$logind_conf"
sed -i 's/#HandleLidSwitchExternalPower=suspend/HandleLidSwitch=ignore/' "$logind_conf"
sed -i 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/' "$logind_conf"
sed -i 's/#IdleAction=suspend/IdleAction=ignore/' "$logind_conf"

systemctl restart systemd-logind

# --- Disable Swap Memory ---
swapoff -a

/usr/bin/clear
