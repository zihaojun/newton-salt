neutron-compute-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
       - tgt_type: list 
       - sls:
         - dev.openstack.compute.neutron

neutron-compute-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.compute.neutron.service
       - require:
         - salt: neutron-compute-init
{% if not salt['pillar.get']('basic:nova:COMPUTE:ADD_NODE_ENABLED',False) %}
         - salt: neutron-service
{% endif %}
