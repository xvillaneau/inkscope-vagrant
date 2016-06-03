# -*- mode: ruby -*-
# vi: set ft=ruby :

# Make the temporary drives directory if needed
unless Dir.exist?("drives")
  Dir.mkdir("drives")
end

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  # Enabled linked cloning for quicker startup
  config.vm.provider 'virtualbox' do |v|
    v.linked_clone = true if Vagrant::VERSION =~ /^1.8/
  end
  # config.hostmanager.enabled = true

  (1..3).each do |i|
    config.vm.define "ceph-node-#{i}" do |node|

      # Add two drives per VM
      node.vm.provider 'virtualbox' do |vb|

        # Generate drive paths
        disk1 = File.join(Dir.pwd, "drives", "ceph-node-#{i}_disk-1.vdi")
        disk2 = File.join(Dir.pwd, "drives", "ceph-node-#{i}_disk-2.vdi")

        # Create the drives
        # NOTE: If this fails with VERR_ALREADY_EXISTS because of a previous
        # failure,go into the VirtualBox Virtual Media Manager and remove the
        # faulty declarations
        vb.customize ['createhd', '--filename', disk1, '--size', 10 * 1024]
        vb.customize ['createhd', '--filename', disk2, '--size', 10 * 1024]

        # Attach the drives to the VM
        vb.customize ['storageattach', :id, '--storagectl', 'SATAController',
                      '--port', 1, '--type', 'hdd', '--medium', disk1]
        vb.customize ['storageattach', :id, '--storagectl', 'SATAController',
                      '--port', 2, '--type', 'hdd', '--medium', disk2]
      end

      node.vm.hostname = "ceph-node-#{i}"
      node.vm.network :private_network, ip: "172.71.212.#{100+i}"
      node.vm.provision "shell", path: "scripts/provision-base.sh"
    end
  end

  config.vm.define "admin-node" do |admin|
    admin.vm.hostname = "admin-node"
    admin.vm.network :private_network, ip: "172.71.212.10"
    admin.vm.network :forwarded_port, guest: 8080, host: 7180, host_ip: "127.0.0.1"
    admin.vm.provision "shell", path: "scripts/provision-base.sh"
    admin.vm.provision "shell", path: "scripts/deploy-ceph.sh", privileged: false
    admin.vm.provision "shell", path: "scripts/deploy-inkscope.sh", privileged: false
    admin.vm.provision "shell", path: "scripts/deploy-radosgw.sh", privileged: false
  end

end
