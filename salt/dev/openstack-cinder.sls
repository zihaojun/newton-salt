cinder-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.cinder

cinder-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('mariadb:MASTER') }}
       - sls:
         - dev.openstack.cinder.db
       - require:
         - salt: cinder-init

cinder-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.cinder.service
       - require:
         - salt: cinder-db-init
