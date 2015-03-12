nova-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list 
       - sls:
         - dev.openstack.nova

nova-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:mariadb:MASTER') }}
       - sls:
         - dev.openstack.nova.db
       - require:
         - salt: nova-init
         - salt: galera-cluster-init

nova-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.nova.service
       - require:
         - salt: nova-db-init
         - salt: keystone-add-haproxy
