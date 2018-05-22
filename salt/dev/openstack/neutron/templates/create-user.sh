#!/bin/bash
source /root/adminrc
openstack user create --domain default neutron --password {{ NEUTRON_USER_PASS }}
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://{{ CONTROLLER }}:9696
openstack endpoint create --region RegionOne network internal http://{{ CONTROLLER }}:9696
openstack endpoint create --region RegionOne network admin http://{{ CONTROLLER }}:9696
