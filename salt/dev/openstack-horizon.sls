horizon-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.horizon

openstack-add-haproxy:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.horizon.openstack-haproxy
       - require:
         - salt: horizon-init
         - salt: glance-service
         - salt: nova-service
         - salt: neutron-service
         - salt: cinder-service
         - salt: ceilometer-service
          
