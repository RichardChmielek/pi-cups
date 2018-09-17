#!/bin/bash
DEBIAN_FILE1=$1
dpkg -i $DEBIAN_FILE1 || apt-get --fix-broken install --yes