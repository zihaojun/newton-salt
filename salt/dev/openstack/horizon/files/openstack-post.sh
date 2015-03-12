#!/bin/bash
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /root/keystonerc
#default subnet of ext-net is sub-ext
#default subnet of int-net is sub-int
admin_tenant=`keystone tenant-list|grep 'admin'|awk '{print $2}'`

glance image-create --name=cirros --disk-format=qcow2 \
--container-format=bare --is-public=yes --copy-from http://172.16.199.249/tmp/cirros.img 

neutron net-create  vlan200 --provider:network_type vlan \
--provider:physical_network physnet1 --provider:segmentation_id 200 \
--tenant-id $admin_tenant

neutron subnet-create --name sub-vlan200 --tenant-id $admin_tenant --dns-nameserver 8.8.8.8 \
--gateway 192.168.200.1 vlan200 192.168.200.0/24

