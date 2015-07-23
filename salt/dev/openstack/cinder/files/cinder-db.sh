#!/bin/bash

openstack-config --set /etc/cinder/cinder.conf database connection mysql://{{MYSQL_CINDER_USER}}:{{MYSQL_CINDER_PASS}}@{{VIP}}/{{MYSQL_CINDER_DBNAME}}
