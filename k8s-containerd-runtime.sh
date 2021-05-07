#!bin/bash -e

# Install and configure containerd as a Kubernetes Container Runtime

echo "Configure required modules"
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

echo "\nSetup required sysctl params, these persist across reboots."

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

echo "\nApply systcl parameters without reboot to current running envorinment"

sudo sysctl --system

echo "\nInstall containerd packages"
sudo apt update
sudo apt install -y containerd

echo "\nRestart containerd"
sudo systemctl restart containerd

echo "\nCreate a containerd configuration file"
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# usar sed para injectar essa linha em /etc/containerd/config.toml na linha 86
#[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#    SystemdCgroup = true

echo "\nUsing the systemd cgroup driver"
cat /vagrant/containerd/config.toml >/etc/containerd/config.toml

echo "\nRestart containerd"
sudo systemctl restart containerd
