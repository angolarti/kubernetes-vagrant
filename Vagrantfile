VAGRANTFILE_API_VERSION = "2"
OS_BOX="ubuntu/focal64"

MEMORY = 2048
CPU_CORE = 2
MASTER_NODE = "elliot-01"

INET_IFACE="enp0s20u2"
INET_WIFI="wlp4s0"

$kube_node_join_in_cluster = <<-'SCRIPT'
  ENV['KUBE_TOKEN_JOIN']=$(kubeadm tokens list)
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  (1..3).each do |i|
    config.vm.define "elliot-0#{i}" do |node|
      node.vm.box = OS_BOX
      node.vm.hostname = "elliot-0#{i}"
      node.vm.network "public_network",
        use_dhcp_assigned_default_route: true,  bridge: [
          # INET_IFACE,
          INET_WIFI,
      ],
      adapter: 2,
      ip: "192.168.0.20#{i}"

      node.vm.provision "cluster-tools",
        type: "shell",
        preserve_order: true,
        path: ".vagrant/cluster-tools.sh"

      node.vm.provision "runtime-container-config",
        type: "shell",
        preserve_order: true,
        path: ".vagrant/runtime-container-config.sh"
      if node.vm.hostname == MASTER_NODE then
        node.vm.provider "virtualbox" do |vb|
          vb.name = "elliot-0#{i}"
          vb.memory = MEMORY
          vb.cpus = CPU_CORE
        end
        node.vm.provision "k8s-init-cluster",
        type: "shell",
        preserve_order: true,
        path: ".vagrant/k8s-init-cluster.sh"
        node.vm.synced_folder "token-vm-k8s", "/home/vagrant/token", 
          SharedFoldersEnableSymlinksCreate: false
      else
        node.vm.provider "virtualbox" do |vb|
          vb.name = "elliot-0#{i}"
          vb.memory = 1024
          vb.cpus = 2
        end
        node.vm.provision "file",
          source: "token-vm-k8s/.token_join",
          destination: "/home/vagrant/.token_join"

        node.vm.provision "node-join-in-cluster",
          type: "shell",
          preserve_order: true,
          inline: "cat /home/vagrant/.token_join | bash"
      end
      node.vm.provision "reboot-system",
          type: "shell",
          preserve_order: true,
          inline: "reboot"
    end
  end
end