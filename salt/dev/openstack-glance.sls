glance-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.glance
{% if salt['pillar.get']('basic:cinder:BACKENDS') == 'glusterfs' and not salt['pillar.get']('basic:storage-common:ADD_NODE_ENABLED',False) %}
       - require:
         - salt: glusterfs-volume 
{% endif %}

glance-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:mariadb:MASTER') }}
       - sls:
         - dev.openstack.glance.db
       - require:
         - salt: glance-init
         - salt: galera-cluster-init

glance-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.glance.service
       - require:
         - salt: glance-db-init
         - salt: keystone-add-haproxy
