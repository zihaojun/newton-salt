#!/bin/bash

openstack-config --set /etc/neutron/neutron.conf database connection mysql://{{MYSQL_NEUTRON_USER}}:{{MYSQL_NEUTRON_PASS}}@{{VIP}}/{{MYSQL_NEUTRON_DBNAME}}
