#!/bin/bash

openstack-config --set /etc/glance/glance-api.conf database connection mysql://{{MYSQL_GLANCE_USER}}:{{MYSQL_GLANCE_PASS}}@{{VIP}}/{{MYSQL_GLANCE_DBNAME}}

openstack-config --set /etc/glance/glance-registry.conf database connection mysql://{{MYSQL_GLANCE_USER}}:{{MYSQL_GLANCE_PASS}}@{{VIP}}/{{MYSQL_GLANCE_DBNAME}}
