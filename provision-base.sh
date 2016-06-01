# apt-get install ceph

LOCK_DIR='/var/vagrant/locks'
mkdir -p $LOCK_DIR

SSH_LOCK=$LOCK_DIR/ssh.lock
if [ ! -e "$SSH_LOCK" ]; then
  echo "Initiating SSH key pairs for ceph"
  SSH_DIR='/home/vagrant/.ssh'
  pushd /vagrant
  cp vagrant-key $SSH_DIR/id_rsa
  chmod 600 $SSH_DIR/id_rsa
  chown vagrant:vagrant $SSH_DIR/id_rsa
  cat vagrant-key.pub >> $SSH_DIR/authorized_keys
  popd
fi
touch $SSH_LOCK

HOSTS_LOCK=$LOCK_DIR/hosts.lock
if [ ! -e "$HOSTS_LOCK" ]; then
  echo "Adding hosts to /etc/hosts"
  echo "172.71.212.10  admin-node" >> /etc/hosts
  echo "172.71.212.101 ceph-node-1" >> /etc/hosts
  echo "172.71.212.102 ceph-node-2" >> /etc/hosts
  echo "172.71.212.103 ceph-node-3" >> /etc/hosts
fi
touch $HOSTS_LOCK

APT_BASE_LOCK=$LOCK_DIR/apt_base.lock
if [ ! -e "$APT_BASE_LOCK" ]; then
  echo "Installing required packages"
  apt-get update
  apt-get install -y ceph
fi
touch $APT_BASE_LOCK
