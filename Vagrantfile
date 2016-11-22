# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "penumbra-opencv"
  config.vm.define :opencv

  # Port forwarding for Jupyter
  config.vm.network "forwarded_port", guest: 8888, host: 8888

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Enable SSH agent forwarding.
  config.ssh.forward_agent = true

  # Enable X forwarding
  config.ssh.forward_x11 = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # VirtualBox VM configuration
  config.vm.provider "virtualbox" do |vb|
    # Customise memory and CPU
    vb.customize ["modifyvm", :id, "--memory", "8192"]
    vb.customize ["modifyvm", :id, "--cpus", "4"]

    # Don't boot with headless mode
    # vb.gui = true

    # Enable the VM's virtual USB controller and enable virtual USB 2.0 controller
    vb.customize ["modifyvm", :id, "--usb", "on", "--usbehci", "on"]
  end

  config.vm.provision "shell", path: "bootstrap.sh"
end
