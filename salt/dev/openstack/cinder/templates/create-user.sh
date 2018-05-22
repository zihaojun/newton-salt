#!/bin/bash
source /root/adminrc
openstack user create --domain default cinder --password {{ CINDER_USER_PASS }}
openstack role add --project service --user cinder admin
for ver in {1,2}
do
openstack service create --name cinderv$ver --description "OpenStack Block Storage" volumev$ver
openstack endpoint create --region RegionOne volumev$ver public http://{{ CONTROLLER }}:8776/v$ver/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev$ver internal http://{{ CONTROLLER }}:8776/v$ver/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev$ver admin http://{{ CONTROLLER }}:8776/v$ver/%\(tenant_id\)s
done
