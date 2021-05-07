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
    
    control.vm.provision "k8s-containerd-runtime",
      type: "shell",
      preserve_order: true,
      path: "k8s-containerd-runtime.sh"
    
    control.vm.provision "k8s-tools",
      type: "shell",
      preserve_order: true,
      path: "k8s-tools.sh"

    control.vm.provision "k8s-cluster-on-primises",
      type: "shell",
      preserve_order: true,
      path: "k8s-cluster-on-primeses.sh"
      control.vm.synced_folder "cluster/", "/home/vagrant/cluster", 
      SharedFoldersEnableSymlinksCreate: false
      control.vm.synced_folder "containerd/", "/home/vagrant/containerd", 
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

      node.vm.provision "k8s-containerd-runtime",
        type: "shell",
        preserve_order: true,
        path: "k8s-containerd-runtime.sh"
        node.vm.synced_folder "containerd/", "/home/vagrant/containerd", 
        SharedFoldersEnableSymlinksCreate: false
      
      node.vm.provision "k8s-tools",
        type: "shell",
        preserve_order: true,
        path: "k8s-tools.sh"
      
      node.vm.provision "file",
        source: "token_cluster/",
        destination: "/home/vagrant/cluster/"

      node.vm.provision "node-join-in-cluster",
        type: "shell",
        preserve_order: true,
        inline: "echo $CLUSTER_TOKEN_JOIN | bash"
    end
  end
end