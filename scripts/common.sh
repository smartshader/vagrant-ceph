#!/bin/bash

set -x
set -e

sed -i 's/START=no/START=yes/' /etc/default/puppet

#AGENT_OPTIONS="--onetime --verbose --ignorecache --no-daemonize --no-usecacheonfailure --no-splay --show_diff --debug --server puppet.test"
AGENT_OPTIONS="--onetime --ignorecache --no-daemonize --no-usecacheonfailure --no-splay --server puppet.test"

# Install ruby 1.8 and ensure it is the default
apt-get install -y ruby1.8
update-alternatives --set ruby /usr/bin/ruby1.8

# And finally, run the puppet agent
puppet agent $AGENT_OPTIONS

# Run two more times on MON servers to generate & export the admin key
if hostname | grep -q "ceph-mon"; then
    puppet agent $AGENT_OPTIONS
    puppet agent $AGENT_OPTIONS
fi

# Run 4/5 more times on OSD servers to get the admin key, format devices, get osd ids, etc. ...
if hostname | grep -q "ceph-osd"; then
    for STEP in $(seq 0 4); do
        echo ================
        echo   STEP $STEP
        echo ================
        blkid > /tmp/blkid_step_$STEP
        facter --puppet|egrep "blkid|ceph" > /tmp/facter_step_$STEP
        ceph osd dump > /tmp/ceph-osd-dump_step_$STEP

        puppet agent $AGENT_OPTIONS
    done
fi

exit 0
