ceilometer-compute-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('nova:COMPUTE:NODES') }}
       - tgt_type: list 
       - sls:
         - dev.openstack.compute.ceilometer

ceilometer-compute-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('nova:COMPUTE:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.compute.ceilometer.service
