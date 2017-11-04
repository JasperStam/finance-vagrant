# -*- mode: ruby -*-
# vi: set ft=ruby :

# ++++ Server Configuration ++++

# Name of your project. This will be used for a number of things, like the name
# of the VM.
project = "finance"
hostname = project + ".dev"
vhosts = [hostname]

# Databases to create in postgres.
databases = ["finance"]

# Set a local private network IP address.
# See http://en.wikipedia.org/wiki/Private_network for explanation
# You can use the following IP ranges:
#   10.0.0.1    - 10.255.255.254
#   172.16.0.1  - 172.31.255.254
#   192.168.0.1 - 192.168.255.254
server_ip = "10.10.10.24"
server_cpus = 2         # Cores
server_memory = 2048    # MB
server_swap = 2048      # Options: false | int (MB) - Guideline: Between one or two times the server_memory

# UTC        for Universal Coordinated Time
# EST        for Eastern Standard Time
# US/Central for American Central
# US/Eastern for American Eastern
server_timezone  = "Europe/Amsterdam"

nodejs_packages = ["npm-check-updates"]

# ---- Server Configuration ----

Vagrant.configure("2") do |config|

  config.vm.box = "debian/jessie64"

  config.ssh.forward_agent = true

  config.vm.define project do |vapro|
  end

  if Vagrant.has_plugin?("vagrant-reverse-proxy")
    config.reverse_proxy.enabled = true
    config.reverse_proxy.vhosts = vhosts
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = false
    # Uncomment the values map thingy if we need multiple vhosts
    config.hostmanager.aliases = vhosts #vhosts.values.map{|x| x.is_a?(String) ? x : x[:host] }.uniq
  end

  # Create a hostname, don't forget to put it to the `hosts` file
  # This will point to the server's default virtual host
  # TO DO: Make this work with virtualhost along-side xip.io URL
  config.vm.hostname = hostname

  # Create a static IP
  # config.vm.network :public_network
  config.vm.network :private_network, ip: server_ip

  # Use NFS for the shared folder
  config.vm.synced_folder ".", "/vagrant",
    id: "core",
    :nfs => true,
    # nolock allows you to edit the files Vagrant also is using without troubles.
    # udp is used for better performance (check https://github.com/mitchellh/vagrant/issues/1706)
    :mount_options => ['nolock,vers=3,udp,noatime,actimeo=2']

  # If using VirtualBox
  config.vm.provider :virtualbox do |vb|

    vb.name = project

    # Set server cpus
    vb.customize ["modifyvm", :id, "--cpus", server_cpus.to_s]

    # Set server memory
    vb.customize ["modifyvm", :id, "--memory", server_memory.to_s]

    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    # If the clock gets more than 15 minutes out of sync (due to your laptop going
    # to sleep for instance, then some 3rd party services will reject requests.
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

    # Prevent VMs running on Ubuntu to lose internet connection;
    # this occurs when `npm install`-ing.
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

  end

  # If using libvirt (QEMU or QEMU+KVM)
  config.vm.provider :libvirt do |libvirt|
    # QEMU-based hypervisors (defaults to kvm if unspecified):
    # - qemu: using software emulation (slower)
    # - kvm: using hardware acceleration (faster, but incompatible with VBox)
    libvirt.driver = "kvm"

    # Set the number of cpus (defaults to 1 if unspecified)
    libvirt.cpus = server_cpus

    # Set the memory limit (defaults to 512 if unspecified).
    libvirt.memory = server_memory
  end

  # ++++ Provisioning ++++
  # Here you choose how the VM will be configured. Normally you want at least
  # base.sh and zsh.sh which will give you a clean base VM. The rest is project
  # specific, such as whether to install PHP / Python / NodeJS and you can 
  # usually copy / paste these scripts and make small modifications.

  # Provision Base Packages.
  config.vm.provision "shell", path: "./scripts/base.sh", privileged: true, args: [server_swap.to_s, server_timezone, project]

  # Add main web server
  config.vm.provision "shell", path: "./scripts/nginx.sh", privileged: true

  # Install zsh with oh-my-zsh
  config.vm.provision "shell", path: "./scripts/zsh.sh", privileged: true

  # Provision Python.
  config.vm.provision "shell", path: "./scripts/python.sh", privileged: true

  # Provision PostgreSQL.
  config.vm.provision "shell", path: "./scripts/pgsql.sh", privileged: true, args: databases

  # Install Nodejs.
  config.vm.provision "shell", path: "./scripts/nodejs.sh", privileged: true, args: nodejs_packages

  # Install app packages and create databases.
  config.vm.provision "shell", path: "./scripts/app_packages.sh", privileged: true, args: databases

  # Clone repo and provision it.
  config.vm.provision "shell", path: "./scripts/app_repo.sh", privileged: false

  # Bootstrap app, such as seeding the database.
  config.vm.provision "shell", path: "./scripts/app_bootstrap.sh", privileged: false

  # ---- Provisioning ----
end
