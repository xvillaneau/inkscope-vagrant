# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  # Enabled linked cloning for quicker startup
  config.vm.provider 'virtualbox' do |v|
    v.linked_clone = true if Vagrant::VERSION =~ /^1.8/
  end
  # config.hostmanager.enabled = true

  config.vm.define "admin-node" do |admin|
    admin.vm.network :private_network, ip: "172.71.212.10"
    admin.vm.hostname = "admin-node"
    admin.vm.provision "shell", path: "provision-base.sh"
  end

  (1..3).each do |i|
    config.vm.define "ceph-node-#{i}" do |node|
      node.vm.network :private_network, ip: "172.71.212.#{100+i}"
      node.vm.hostname = "ceph-node-#{i}"
      node.vm.provision "shell", path: "provision-base.sh"
    end
  end

end
