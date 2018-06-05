#!/usr/bin/env bash

# Script for installing python that just checks a lock file before
# calling apt-get. This shortens deployment time when running
# "vagrant provision" multiple times in a row.

LOCK_FILE=/tmp/python_installed

if [ ! -e "$LOCK_FILE" ]; then
  apt-get install -y python python-apt
fi
touch $LOCK_FILE
