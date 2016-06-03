#!/bin/bash

source /vagrant/scripts/utils.sh || exit 1
pushd $HOME

COLLECTD_LOCK=$VAGRANT_LOCK_DIR/collectd.lock
if [ ! -e "$COLLECTD_LOCK" ]; then
  echo "Installing collectd"

  sudo apt-get install -y collectd

  pushd /etc/collectd
  sudo mv collectd.conf collectd.conf.old
  sudo cp /vagrant/files/collectd.conf .
  popd

  git clone https://github.com/inkscope/collectd-ceph.git
  sudo cp -r collectd-ceph/plugins /usr/lib/collectd/ceph
  sudo cp /vagrant/files/collectd-ceph.conf /etc/collectd/collectd.conf.d/ceph.conf

  sudo service collectd restart

else
  echo "Skipping collectd installation"
fi
sudo touch $COLLECTD_LOCK

INFLUXDB_LOCK=$VAGRANT_LOCK_DIR/influxdb.lock
if [ ! -e "$INFLUXDB_LOCK" ]; then
  echo "Installing collectd"

  curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
  source /etc/lsb-release
  echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

  sudo apt-get update
  sudo apt-get install influxdb

  cat /vagrant/files/influxdb-collectd.conf | sudo tee -a /etc/influxdb/influxdb.conf
  sudo service influxdb start
  sleep 2

  curl -s -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE collectd"

  sed -i "s/influxdb_host/127.0.0.1/" $INKSCOPE_CFG
  sed -i "s/influxdb_port/7186/" $INKSCOPE_CFG
  sudo apache2ctl restart
else
  echo "Skipping InfluxDB installation"
fi
sudo touch $INFLUXDB_LOCK

popd
