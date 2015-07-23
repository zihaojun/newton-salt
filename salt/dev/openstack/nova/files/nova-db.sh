#!/bin/bash

openstack-config --set /etc/nova/nova.conf database connection mysql://{{MYSQL_NOVA_USER}}:{{MYSQL_NOVA_PASS}}@{{VIP}}/{{MYSQL_NOVA_DBNAME}}
