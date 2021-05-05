#!/bin/bash -e

echo "enable module..."
sleep 5
modprobe overlay br_netfilter ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 ip_vs

# Control-plane e Nodes
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack_ipv4
ip_vs
EOF

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-crs.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

echo "Reload sysctl"
sysctl --system
sleep 5

apt update
apt install -y containerd apt-transport-https ca-certificates curl bash-completion

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd

curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install -y kubelet kubeadm kubectl

# Clean apt cache
# apt clean
# rm /var/lib/apt/lists/* 2>&1 /dev/null
# rm /var/lib/apt/lists/partial/* 2>&1 /dev/null
# apt clean
# apt update
# sudo apt full-upgrade -y

