glance-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.glance
{% if salt['pillar.get']('config_ha_install',False) %}
{% if salt['pillar.get']('config_storage_install',True) and 
     salt['pillar.get']('basic:glance:IMAGE_BACKENDS','local') == 'glusterfs' %}
       - require:
         - salt: glusterfs-volume
{% endif %}
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
{% if salt['pillar.get']('config_ha_install',False) %}
         - salt: keystone-add-haproxy
{% endif %}
