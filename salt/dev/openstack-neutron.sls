neutron-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.neutron

neutron-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('mariadb:MASTER') }}
       - sls:
         - dev.openstack.neutron.db
       - require:
         - salt: neutron-init

neutron-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.neutron.service
       - require:
         - salt: neutron-db-init
