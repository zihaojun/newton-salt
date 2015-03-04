glance-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.glance

glance-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('mariadb:MASTER') }}
       - sls:
         - dev.openstack.glance.db
       - require:
         - salt: glance-init

glance-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.glance.service
       - require:
         - salt: glance-db-init
