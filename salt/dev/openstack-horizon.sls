horizon-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.horizon

openstack-add-haproxy:
   salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.horizon.openstack-haproxy
       - require:
         - salt: horizon-init
