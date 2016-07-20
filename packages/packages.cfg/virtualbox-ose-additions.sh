#!/bin/sh

# enable virtualbox guest adittions in rc.conf
echo 'vboxguest_enable="YES"' >> /etc/rc.conf
echo 'vboxservice_enable="NO"' >> /etc/rc.conf
