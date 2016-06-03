#!/bin/bash

source /vagrant/scripts/utils.sh || exit 1
pushd $HOME

RGW_LOCK=$VAGRANT_LOCK_DIR/radosgw.lock
if [ ! -e "$RGW_LOCK" ]; then
  echo "Deploying RADOS Gateway on the admin node"


  sudo ceph auth get-or-create client.radosgw.gateway osd 'allow rwx' \
            mon 'allow rwx' -o /etc/ceph/ceph.client.radosgw.keyring

  pushd deploy-ceph
  cat /vagrant/ceph-radosgw.conf >> ceph.conf
  ceph-deploy --overwrite-conf config push admin-node ceph-node-1 \
                                           ceph-node-2 ceph-node-3
  popd

  sudo apt-get install -y radosgw
  sleep 1

  # Configure Apache2
  sudo cp /vagrant/apache2-radosgw.conf /etc/apache2/sites-available/rgw.conf
  sudo a2enmod rewrite proxy_fcgi
  sudo a2ensite rgw.conf
  sudo service radosgw restart

  # Create an admin user, get its credentials
  out=$(radosgw-admin user create --uid=inkscope --display-name="Inkscope" \
                                  --caps="users=*;metadata=*;buckets=*")
  access_key=$(echo $out | sed -n 's/.*"access_key": "\([A-Z0-9]*\)".*/\1/p')
  secret_match='s#.*"secret_key":\s\?"\([A-Za-z0-9+/]*\)".*#\1#p'
  secret_key=$(echo $out | sed 's#\\/#/#' | sed -n $secret_match)

  # Set the admin credentials in the Inkscope configuration
  sed -i "s#access-key#$access_key#" $INKSCOPE_CFG
  sed -i "s#secret-key#$secret_key#" $INKSCOPE_CFG
  sed -i "s#rgw_host#$ADMIN_HOST#" $INKSCOPE_CFG
  sed -i "s#rgw_port#5480#" $INKSCOPE_CFG

  # Send the configuration to the other nodes
  for s in ceph-node-1 ceph-node-2 ceph-node-3; do
    scp $INKSCOPE_CFG $s:$INKSCOPE_CFG
  done

  sudo apache2ctl restart

else
  echo "Skipping RADOS Gateway deployment"
fi
sudo touch $RGW_LOCK

popd
