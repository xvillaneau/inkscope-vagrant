LOCK_DIR='/var/vagrant/locks'
sudo mkdir -p $LOCK_DIR

INKSCOPE_VERSION='1.4.0.2'
ADMIN_HOST='172.71.212.10'
INKSCOPE_CFG='/opt/inkscope/etc/inkscope.conf'

cd $HOME

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

popd
