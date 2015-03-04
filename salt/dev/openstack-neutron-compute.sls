neutron-compute-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('nova:COMPUTE:NODES') }}
       - tgt_type: list 
       - sls:
         - dev.openstack.compute.neutron

neutron-compute-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('nova:COMPUTE:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.compute.neutron.service
