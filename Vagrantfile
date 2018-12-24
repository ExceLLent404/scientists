# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "scientists"
    vb.memory = 512
    vb.cpus = 1
  end

  config.vm.network "private_network", ip: "192.168.33.15"
  config.vm.network "forwarded_port", guest: 4567, host: 4567

  config.vm.synced_folder ".", "/scientists"

  config.vm.provision "ansible_local" do |ansible|
      ansible.provisioning_path = "/scientists/ansible"
      ansible.playbook = "playbook.yml"
      ansible.inventory_path = "inventory.ini"
      ansible.config_file = "ansible.cfg"
  end

  config.vm.provision "shell", inline: "gem install bundler"
end
