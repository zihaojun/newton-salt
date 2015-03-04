ceilometer-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.ceilometer

ceilometer-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('mariadb:MASTER') }}
       - sls:
         - dev.openstack.ceilometer.db
       - require:
         - salt: ceilometer-init

ceilometer-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.ceilometer.service
       - require:
         - salt: ceilometer-db-init
