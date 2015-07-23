nova-compute-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
       - tgt_type: list 
       - sls:
         - dev.openstack.compute.nova
{% if salt['pillar.get']('config_storage_install',True) and 
      salt['pillar.get']('basic:nova:COMPUTE:INSTANCE_BACKENDS','local') == 'glusterfs' and 
      not salt['pillar.get']('basic:storage-common:ADD_NODE_ENABLED',False) %}
       - require:
         - salt: glusterfs-volume
{% endif %}

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
