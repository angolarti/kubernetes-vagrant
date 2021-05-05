VAGRANTFILE_API_VERSION = "2"
OS_BOX="ubuntu/focal64"

MEMORY = 3072
CPU_CORE = 2
MASTER_NODE = "k8s-control"
INET_IFACE="enp0s20u2"
INET_WIFI="wlp4s0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = OS_BOX

  config.vm.define MASTER_NODE do |control|
    control.vm.hostname = MASTER_NODE

    control.vm.provider "virtualbox" do |ctl|
      ctl.name   = MASTER_NODE
      ctl.memory = MEMORY
      ctl.cpus   = CPU_CORE
    end
    control.vm.network "public_network",
      use_dhcp_assigned_default_route: true,  bridge: [
        INET_WIFI ], ip: "192.168.1.20"
    
    control.vm.provision "install-and-config-k8s-nodes",
      type: "shell",
      preserve_order: true,
      path: "nodes.sh"
    
    control.vm.provision "init-cluster-k8s",
      type: "shell",
      preserve_order: true,
      path: "control.sh"
      control.vm.synced_folder "token_cluster", "/home/vagrant/token", 
      SharedFoldersEnableSymlinksCreate: false
  end

  (1..2).each do |i|
    config.vm.define "k8s-node0#{i}" do |node|
      node.vm.hostname = "k8s-node0#{i}"

      node.vm.provider "virtualbox" do |vb|
        vb.name   = "k8s-node0#{i}"
        vb.memory = 2048
        vb.cpus   = CPU_CORE
      end
      node.vm.network "public_network",
        use_dhcp_assigned_default_route: true,  bridge: [
          INET_WIFI ], ip: "192.168.1.2#{i}"

      node.vm.provision "install-and-config-k8s-nodes",
        type: "shell",
        preserve_order: true,
        path: "nodes.sh"
      
      node.vm.provision "enable br_netfilter kernel module",
        type: "shell",
        preserve_order: true,
        inline: "modprobe br_netfilter"
      
      node.vm.provision "file",
        source: "token_cluster/join",
        destination: "/home/vagrant/token"

      node.vm.provision "node-join-in-cluster",
        type: "shell",
        preserve_order: true,
        inline: "cat /home/vagrant/token | bash"
    end
  end
end