
# Inkscope on Vagrant

This in an automated demonstration of Inkscope, an Open-Source visual administration interface for Ceph.

Copyright (c) 2016 Xavier Villaneau, under the MIT license.

## Acknowledgments

- The main part of the show is [Inkscope](https://github.com/inkscope/inkscope) by Alain Dechorgnat. Try it yourself, it's easy now!
- [Multinode Ceph on Vagrant](https://github.com/carmstrong/multinode-ceph-vagrant) by Carl Armstrong, which was a strong inspiration and reference to start from.
- [Ceph](https://ceph.com) by Sage Weil, the Open-Source Distributed Storage System on which everything here is built.

## Requirements

- This demonstration relies on virtualization. It therefore requires hardware that supports it (not all CPUs can do it), 4GB or RAM at the *very* least, 8GB of RAM or more recommended.
- [Vagrant](https://www.vagrantup.com/) with [VirtualBox](https://www.virtualbox.org/) as provider.
- An internet access. There is a one-time download of the Ubuntu Trusty base box (approx 500MB) then around 250MB of download every time the cluster is set up.

## Usage

Clone the repository:
```
git clone https://github.com/xvillaneau/inkscope-vagrant.git
cd inkscope-vagrant
```

Then just run: `vagrant up`

The installation then takes from 10 to 30 minutes or more, depending on the your internet speed. Once it's over, you may access the inkscope UI on `http://127.0.0.1:7180`

If you want to access the admin node in the CLI, do it with `vagrant ssh admin-node`

To destroy the cluster, use `vagrant destroy -f`

**NOTE:** Inkscope-Vagrant does *not* currently support stopping then re-starting the cluster with `vagrant halt` or `vagrant suspend`. The cluster must be destroyed than re-created.

## So what's in there?

- A minimal Ceph installation with three nodes, each hosting one MON (monitor) and two drives of 10GB used as OSDs (but only 5GB is used because the journal takes the rest of the space). Currently, the installed version of Ceph is 0.80 (Firefly). One of these nodes is used as MDS for CephFS
- An admin node that runs Inkscope on port 8080, the Ceph REST API on port 7171, RADOS Gateway on port 5380, Collectd for Ceph and InfluxDB (ports 8083 for UI, 8086 for data, 8096 for collectd). Ports forwarded to the Vagrant host are 8080 to 7180 (Inkscope) and 8086 to 7186 (InfluxDB).
- All nodes run Ubuntu 14.04 amd64

## Ideas for the future

Which ones would you like to see first?
- Enable Vagrant paquet cache to cut on download time after the first deployment (still waiting for Vagrant plugins to be fixed in Ubuntu 16.04)
- Unified config file to select components to install
- Ability to change how many hosts or monitors are created
- Ability to adjust number and size of the OSD drives
- Ability to choose a Ceph version
