#!/bin/bash

openstack-config --set /etc/heat/heat.conf database connection mysql://{{MYSQL_HEAT_USER}}:{{MYSQL_HEAT_PASS}}@{{VIP}}/{{MYSQL_HEAT_DBNAME}}
