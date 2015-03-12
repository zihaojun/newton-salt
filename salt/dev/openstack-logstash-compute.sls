logstash-compute-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.compute.logstash

logstash-compute-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.compute.logstash.service
       - require:
         - salt: logstash-compute-init
{% if not salt['pillar.get']('basic:nova:COMPUTE:ADD_NODE_ENABLED',False) %}
         - salt: logstash-service
{% endif %}
