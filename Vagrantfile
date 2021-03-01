# -*- mode: ruby -*-
# vi:set ft=ruby sw=2 ts=2 sts=2:

# Define the number of master and worker nodes
# If this number is changed, remember to update setup-hosts.sh script with the new hosts IP details in /etc/hosts of each VM.
MASTER_NODES = 2
WORKER_NODES = 3

NETWORK = "192.168.10."
MASTER_IP_START = 10
WORKER_IP_START = 20

LB_IP_START = 30
EX_LB_IP_START = 5

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/focal64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Provision Master Nodes
  (1..MASTER_NODES).each do |i|
      config.vm.define "master-#{i}" do |node|
        # Name shown in the GUI
        node.vm.provider "virtualbox" do |vb|
            vb.check_guest_additions = false
            vb.name = "k8s-master-#{i}"
            vb.memory = 2048
            vb.cpus = 2
        end
        node.vm.hostname = "master-#{i}"
        node.vm.network :private_network, ip: NETWORK + "#{MASTER_IP_START + i}"
        node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"

        node.vm.provision "setup-k8s-base", type: "shell", :path => "./k8s-vm-setup.sh"
      end
  end

  # Provision Worker Nodes
  (1..WORKER_NODES).each do |i|
    config.vm.define "worker-#{i}" do |node|
        node.vm.provider "virtualbox" do |vb|
            vb.name = "k8s-worker-#{i}"
            vb.memory = 1024
            vb.cpus = 1
        end
        node.vm.hostname = "worker-#{i}"
        node.vm.network :private_network, ip: NETWORK + "#{WORKER_IP_START + i}"
		    node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"

        node.vm.provision "setup-k8s-base", type: "shell", :path => "./k8s-vm-setup.sh"
    end
  end

  # Provision Load Balancer Node
  config.vm.define "lb" do |node|
    node.vm.provider "virtualbox" do |vb|
        vb.name = "k8s-ha-lb"
        vb.memory = 512
        vb.cpus = 1
    end
    node.vm.hostname = "loadbalancer"
    node.vm.network :private_network, ip: NETWORK + "#{LB_IP_START}"
	  node.vm.network "forwarded_port", guest: 22, host: 2730

    node.vm.provision "setup-ha", type: "shell", :path => "./haproxy-setup.sh"

  end

end
