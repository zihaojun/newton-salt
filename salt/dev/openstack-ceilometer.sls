ceilometer-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.ceilometer

ceilometer-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:mariadb:MASTER') }}
       - sls:
         - dev.openstack.ceilometer.db
       - require:
         - salt: ceilometer-init
         - salt: mongodb-cluster-init 

ceilometer-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.ceilometer.service
       - require:
         - salt: ceilometer-db-init
         - salt: keystone-add-haproxy
