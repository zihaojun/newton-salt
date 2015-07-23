#!/bin/bash
#description: lvm cinder-volumes

fallocate -l 20G /var/lib/cinder-volumes
losetup /dev/loop2 /var/lib/cinder-volumes
pvcreate /dev/loop2
vgcreate cinder-volumes /dev/loop2
