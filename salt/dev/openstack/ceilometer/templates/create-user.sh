#!/bin/bash
source /root/adminrc
mongo --host {{ CONTROLLER }} --eval 'db = db.getSiblingDB("ceilometer");db.createUser({user: "ceilometer",pwd: "{{ CEILOMETER_DBPASS }}",roles: [ "readWrite", "dbAdmin" ]})'
openstack user create --domain default ceilometer --password {{ CEILOMETER_USER_PASS }}
openstack role add --project service --user ceilometer admin
openstack service create --name ceilometer --description "Telemetry" metering
openstack endpoint create --region RegionOne metering public http://{{ CONTROLLER }}:8777
openstack endpoint create --region RegionOne metering internal http://{{ CONTROLLER }}:8777
openstack endpoint create --region RegionOne metering admin http://{{ CONTROLLER }}:8777


