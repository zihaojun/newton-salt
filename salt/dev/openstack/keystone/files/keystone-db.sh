#!/bin/bash

openstack-config --set /etc/keystone/keystone.conf database connection mysql://{{MYSQL_KEYSTONE_USER}}:{{MYSQL_KEYSTONE_PASS}}@{{VIP}}/{{MYSQL_KEYSTONE_DBNAME}}
