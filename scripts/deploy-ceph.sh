
LOCK_DIR='/var/vagrant/locks'
sudo mkdir -p $LOCK_DIR

# Deploy a basic Ceph cluster
CEPH_LOCK=$LOCK_DIR/ceph-init.lock
if [ ! -e "$CEPH_LOCK" ]; then
  echo "Deploying Ceph cluster"
  cd $HOME
  mkdir -p deploy-ceph
  cd deploy-ceph

  sudo apt-get install -y ceph-deploy

  # Declare initial monitors
  ceph-deploy new ceph-node-1 ceph-node-2 ceph-node-3

  # Tweak ceph.conf a bit
  echo 'osd pool default size = 2' >> ceph.conf
  echo 'osd pool default pg num = 32' >> ceph.conf
  echo 'osd pool default pgp num = 32' >> ceph.conf

  # Deploy the monitors and the admin keyring
  ceph-deploy mon create-initial
  ceph-deploy admin admin-node ceph-node-1 ceph-node-2 ceph-node-3

  # Add the OSDs
  # NOTE: The OSDs are created with a weight of 0 and must be reweighted
  ceph-deploy osd create ceph-node-1:/dev/sdb ceph-node-1:/dev/sdc
  ceph osd crush reweight osd.0 1
  ceph osd crush reweight osd.1 1

  ceph-deploy osd create ceph-node-2:/dev/sdb ceph-node-2:/dev/sdc
  ceph osd crush reweight osd.2 1
  ceph osd crush reweight osd.3 1

  ceph-deploy osd create ceph-node-3:/dev/sdb ceph-node-3:/dev/sdc
  ceph osd crush reweight osd.4 1
  ceph osd crush reweight osd.5 1
else
  echo "Skipping Ceph deployment"
fi
sudo touch $CEPH_LOCK
