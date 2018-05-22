#!/bin/bash
source /root/adminrc
openstack user create --domain default glance --password {{ GLANCE_USER_PASS }}
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://{{ CONTROLLER }}:9292
openstack endpoint create --region RegionOne image internal http://{{ CONTROLLER }}:9292
openstack endpoint create --region RegionOne image admin http://{{ CONTROLLER }}:9292

