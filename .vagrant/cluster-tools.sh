#!/bin/bash

echo "Upgrade distribuition"
apt update && apt dist-upgrade -y

echo "Install bash completion"
apt install -y bash-completion

echo "Install Docker Engine..."
curl -fsSL https://get.docker.com | bash

echo "Add vagrant user to docker group"
usermod -aG docker vagrant

echo "Show containers..."
docker container ls

# Kubernetes config
echo "Add kubernetes repository..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt update
apt install -y kubeadm kubelet kubectl

# Clean apt cache
apt clean
rm /var/lib/apt/lists/*
rm /var/lib/apt/lists/partial/*
apt clean
apt update