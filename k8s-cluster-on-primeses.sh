#!/bin/bash -e

HOME=/home/vagrant

echo "\nDownload images of the components by cluster..."
sudo kubeadm config images pull

echo "\nDisable swap"
sudo swapoff -a

echo "\nGet IP network"
IP=$(hostname -I | awk -F' ' '{ print $2 }')
echo "\nCreating a cluster with kubeadm"
sudo kubeadm init --apiserver-cert-extra-sans=$IP --apiserver-advertise-address=$IP \
    --ignore-preflight-errors=Swap

echo "\nTo make kubectl work for your non-root user, run these commands, which are also part of the kubeadm init outpu"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown vagrant:vagrant $HOME/.kube/config

echo "\nAlternatively, if you are the root user, you can run"
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "\nInstalling a Pod network add-on"
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo "\nList Nodes..."
kubectl get nodes

echo "\nForce kubectl bash completion active now"
kubectl completion bash >/etc/bash_completion.d/kubectl
source <(kubectl completion bash)

echo "\nNew cluster token"
export CLUSTER_TOKEN_JOIN=$(sudo kubeadm token create --print-join-command)
echo $CLUSTER_TOKEN_JOIN >$HOME/cluster/token

echo "\n(Optional) Controlling your cluster from machines other than the control-plane node"
cp -i /etc/kubernetes/admin.conf $HOME/cluster/
