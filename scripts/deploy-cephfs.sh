#!/bin/bash

source /vagrant/scripts/utils.sh || exit 1
pushd $HOME

CEPHFS_LOCK=$VAGRANT_LOCK_DIR/cephfs.lock
if [ ! -e "$CEPHFS_LOCK" ]; then
  echo "Preparing CephFS"
  ssh ceph-node-1 'sudo apt-get install ceph-mds'
  pushd deploy-ceph
  ceph-deploy --overwrite-conf mds create ceph-node-1
  popd
else
  echo "Skipping CephFS preparation"
fi
sudo touch $CEPHFS_LOCK

popd
