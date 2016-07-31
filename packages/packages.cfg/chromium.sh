#!/bin/sh

# memory support foe chromium
grep -q "kern.ipc.shm_allow_removed=1" /etc/sysctl.conf
if [ $? -ne 0 ]; then
    echo 'kern.ipc.shm_allow_removed=1' >> /etc/sysctl.conf
fi

