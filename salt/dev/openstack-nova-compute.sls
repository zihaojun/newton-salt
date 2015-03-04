nova-compute-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('nova:COMPUTE:NODES') }}
       - tgt_type: list 
       - sls:
         - dev.openstack.compute.nova

nova-compute-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('nova:COMPUTE:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.compute.nova.service
