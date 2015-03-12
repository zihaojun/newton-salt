cinder-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.cinder

cinder-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:mariadb:MASTER') }}
       - sls:
         - dev.openstack.cinder.db
       - require:
         - salt: cinder-init
         - salt: galera-cluster-init

cinder-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.cinder.service
       - require:
         - salt: cinder-db-init
         - salt: keystone-add-haproxy
