LOCK_DIR='/var/vagrant/locks'
sudo mkdir -p $LOCK_DIR

INKSCOPE_VERSION='1.4.0.2'
ADMIN_HOST='172.71.212.10'
INKSCOPE_CFG='/opt/inkscope/etc/inkscope.conf'

cd $HOME

# Initialize Inkscope repository
# TODO: Actually not a repository, this could be improved
INIT_LOCK=$LOCK_DIR/inkscope-init.lock
if [ ! -e "$INIT_LOCK" ]; then
  echo "Downloading Inkscope packages"
  sudo apt-get install -y git
  git clone https://github.com/inkscope/inkscope-packaging.git
else
  echo "Skipping Inkscope download"
fi
sudo touch $INIT_LOCK

pushd inkscope-packaging/DEBS

# Install Ceph REST API
RESTAPI_LOCK=$LOCK_DIR/inkscope-restapi.lock
if [ ! -e "$RESTAPI_LOCK" ]; then
  echo "Installing Ceph REST API"

  # Update Ceph configuration
  pushd $HOME/deploy-ceph
  echo '[client.admin]' >> ceph.conf
  echo 'restapi base url = /ceph_rest_api/api/v0.1' >> ceph.conf
  echo "public addr = $ADMIN_HOST:7171]" >> ceph.conf
  ceph-deploy --overwrite-conf config push admin-node ceph-node-1 ceph-node-2 ceph-node-3
  popd

  # Install package, apply patch, start process
  sudo dpkg -i inkscope-cephrestapi_$INKSCOPE_VERSION.deb
  sudo chown root:root /etc/init.d/ceph-rest-api /etc/logrotate.d/cephrestapi
  sudo patch /etc/init.d/ceph-rest-api /vagrant/ceph-rest-api.patch
  sudo service ceph-rest-api start
else
  echo "Skipping Ceph REST API install"
fi
sudo touch $RESTAPI_LOCK

# Install and configure MongoDB for Inkscope
MONGO_LOCK=$LOCK_DIR/inkscope-mongodb.lock
if [ ! -e "$MONGO_LOCK" ]; then
  echo "Installing MongoDB"
  sudo apt-get install -y mongodb
  sudo sed -i "s/^bind_ip.*/bind_ip = $ADMIN_HOST/" /etc/mongodb.conf
  sudo service mongodb restart
  sleep 2
  mongo 172.71.212.10/admin /vagrant/mongodb-2.4-create-admin.js
else
  echo "Skipping MongoDB installation"
fi
sudo touch $MONGO_LOCK

# Install, configure and deploy the common inkscope components
COMMON_LOCK=$LOCK_DIR/inkscope-common.lock
if [ ! -e "$COMMON_LOCK" ]; then
  echo "Installing Inkscope Common components"

  COMMON_PKG="inkscope-common_$INKSCOPE_VERSION.deb"
  sudo dpkg -i $COMMON_PKG

  # Editing config file
  # First line updates the configuration template for easier fill-in
  sed -i 's/"ceph_rest_api":.*/"ceph_rest_api": "cra_host:cra_port",/' $INKSCOPE_CFG
  sed -i "s/cra_host/$ADMIN_HOST/" $INKSCOPE_CFG
  sed -i 's/cra_port/7171/' $INKSCOPE_CFG
  sed -i "s/mpongo_host/$ADMIN_HOST/" $INKSCOPE_CFG
  sed -i "s/inkscope_host/127.0.0.1/" $INKSCOPE_CFG
  sed -i "s/inkscope_port/7180/" $INKSCOPE_CFG

  # Send the package onto the other nodes, install it, push the configuration
  for s in ceph-node-1 ceph-node-2 ceph-node-3; do
    scp $COMMON_PKG $s:.
    ssh $s "sudo dpkg -i $COMMON_PKG"
    scp $INKSCOPE_CFG $s:$INKSCOPE_CFG
  done
else
  echo "Skipping inkscope-common installation"
fi

# Install the Inkscope Cephprobe on the admin node
CEPHPROBE_LOCK=$LOCK_DIR/inkscope-cephprobe.lock
if [ ! -e "$CEPHPROBE_LOCK" ]; then
  echo "Installing Inkscope cephprobe"
  sudo apt-get install -y python-pymongo python-psutil
  sudo dpkg -i inkscope-cephprobe_$INKSCOPE_VERSION.deb
  sudo service cephprobe start
else
  echo "Skipping cephprobe installation"
fi
sudo touch $CEPHPROBE_LOCK

popd
