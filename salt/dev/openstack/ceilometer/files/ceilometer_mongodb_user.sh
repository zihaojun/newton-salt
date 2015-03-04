#!/bin/bash

mongo --host {{IPADDR}}  --eval '
db = db.getSiblingDB("{{MONGODB_CEILOMETER_DBNAME}}");
db.createUser({user: "{{MONGODB_CEILOMETER_USER}}",
            pwd: "{{MONGODB_CEILOMETER_PASS}}",
            roles: [ "readWrite", "dbAdmin" ]})'
