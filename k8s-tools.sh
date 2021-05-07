#!/bin/bash -e

echo "\nletting iptables see bridged traffic"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
EOF
sudo sysctl --system

echo "\nInstall kubeadm, kubelet and kubectl"
echo "Update the apt package index and install packages needed to use the Kubernetes apt repository"
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl bash-completion

echo "\nDownload the Google Cloud public signing key"
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "\nAdd the Kubernetes apt repository"
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "\nUpdate apt package index, install kubelet, kubeadm and kubectl, and pin their version"
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
