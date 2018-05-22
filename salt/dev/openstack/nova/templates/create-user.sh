#!/bin/bash
source /root/adminrc
openstack user create --domain default nova --password {{ NOVA_USER_PASS }}
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://{{ CONTROLLER }}:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://{{ CONTROLLER }}:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://{{ CONTROLLER }}:8774/v2.1/%\(tenant_id\)s
