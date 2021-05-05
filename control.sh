#!/bin/bash

USER_HOME=/home/vagrant

echo "Download images of the components by cluster..."
kubeadm config images pull

echo "Disable swap"
swapoff -a

# Enable kernel modules
echo "Enable kernel moludes..."
modprobe br_netfilter ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 ip_vs

# No Contol-plane
echo "Initialize cluster..."
kubeadm init --apiserver-cert-extra-sans=192.168.1.20 --apiserver-advertise-address=192.168.1.20 \
  --ignore-preflight-errors=Swap

echo "configure runtime container for root..."
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "configure runtime container for normal user..."
mkdir -p $USER_HOME/.kube
cp -i /etc/kubernetes/admin.conf $USER_HOME/.kube/config
chown vagrant:vagrant $USER_HOME/.kube/config

# No control-plane
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo "List Nodes..."
kubectl get nodes

kubectl completion bash > /etc/bash_completion.d/kubectl
echo "Force kubectl bash completion active now"
source <(kubectl completion bash)

kubeadm token create --print-join-command > $USER_HOME/token/join
