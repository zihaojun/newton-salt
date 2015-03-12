nova-compute-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
       - tgt_type: list 
       - sls:
         - dev.openstack.compute.nova

nova-compute-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.compute.nova.service
       - require:
         - salt: nova-compute-init
{% if not salt['pillar.get']('basic:nova:COMPUTE:ADD_NODE_ENABLED',False) %}
         - salt: nova-service
{% endif %}
