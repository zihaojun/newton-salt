ceilometer-compute-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
       - tgt_type: list 
       - sls:
         - dev.openstack.compute.ceilometer

ceilometer-compute-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.compute.ceilometer.service
       - require:
         - salt: ceilometer-compute-init
{% if not salt['pillar.get']('basic:nova:COMPUTE:ADD_NODE_ENABLED',False) %}
         - salt: ceilometer-service
{% endif %}
