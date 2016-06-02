
LOCK_DIR='/var/vagrant/locks'
mkdir -p $LOCK_DIR

# Configure everything SSH-related
SSH_LOCK=$LOCK_DIR/ssh.lock
if [ ! -e "$SSH_LOCK" ]; then
  echo "Initiating SSH key pairs for ceph"
  SSH_DIR='/home/vagrant/.ssh'

  # Copy the key pair to all machines to enable password-less access for Ceph
  pushd /vagrant
  cp vagrant-key $SSH_DIR/id_rsa
  chmod 600 $SSH_DIR/id_rsa
  chown vagrant:vagrant $SSH_DIR/id_rsa
  cat vagrant-key.pub >> $SSH_DIR/authorized_keys
  popd

  # Prevent SSH for prompting for host keys validation
  echo -e 'Host admin-node\n\tStrictHostKeyChecking no' >> $SSH_DIR/config
  echo -e 'Host ceph-node-1\n\tStrictHostKeyChecking no' >> $SSH_DIR/config
  echo -e 'Host ceph-node-2\n\tStrictHostKeyChecking no' >> $SSH_DIR/config
  echo -e 'Host ceph-node-3\n\tStrictHostKeyChecking no' >> $SSH_DIR/config

else
  echo "Skipping SSH configuration"
fi
touch $SSH_LOCK

# Hardcode the hostnames into /etc/hosts
HOSTS_LOCK=$LOCK_DIR/hosts.lock
if [ ! -e "$HOSTS_LOCK" ]; then
  echo "Adding hosts to /etc/hosts"
  echo "172.71.212.10  admin-node" >> /etc/hosts
  echo "172.71.212.101 ceph-node-1" >> /etc/hosts
  echo "172.71.212.102 ceph-node-2" >> /etc/hosts
  echo "172.71.212.103 ceph-node-3" >> /etc/hosts
else
  echo "Skipping /etc/hosts configuration"
fi
touch $HOSTS_LOCK

# Install ceph
# TODO: Trusty default is Ceph 0.80, it could be interesting to have other versions
APT_BASE_LOCK=$LOCK_DIR/apt_base.lock
if [ ! -e "$APT_BASE_LOCK" ]; then
  echo "Installing required packages"
  apt-get update
  apt-get install -y ceph
else
  echo "Skipping packages install"
fi
touch $APT_BASE_LOCK
