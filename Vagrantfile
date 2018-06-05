
ansible_provision = proc do |ansible|
  ansible.playbook = "deploy/deploy.yml"
  ansible.groups = {
    "data"  => ["ceph-node-1", "ceph-node-2", "ceph-node-3"],
    "admin" => ["admin-node"],
    "all:children" => ["data", "admin"]
  }
  ansible.limit = 'all'
end

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/xenial64"
  # Enabled linked cloning for quicker startup
  config.vm.provider 'virtualbox' do |v|
    v.linked_clone = true if Vagrant::VERSION =~ /^1.8/
  end
  config.hostmanager.enabled = true

  (1..3).each do |i|
    config.vm.define "ceph-node-#{i}" do |node|
      node.vm.hostname = "ceph-node-#{i}"
      node.vm.network :private_network, ip: "172.71.212.#{100+i}"
      node.vm.provision "shell", path: "deploy/install_python.sh"
    end
  end

  config.vm.define "admin-node" do |admin|
    admin.vm.hostname = "admin-node"
    admin.vm.network :private_network, ip: "172.71.212.10"
    admin.vm.network :forwarded_port, guest: 8080, host: 7180, host_ip: "127.0.0.1"
    admin.vm.network :forwarded_port, guest: 8086, host: 7186, host_ip: "127.0.0.1"

    admin.vm.provision "shell", path: "deploy/install_python.sh"
    admin.vm.provision "ansible", &ansible_provision

    # admin.vm.provision "shell", path: "scripts/deploy-inkscope.sh", privileged: false
    # admin.vm.provision "shell", path: "scripts/deploy-radosgw.sh", privileged: false
    # admin.vm.provision "shell", path: "scripts/deploy-cephfs.sh", privileged: false
    # admin.vm.provision "shell", path: "scripts/deploy-monitoring.sh", privileged: false

  end
end
