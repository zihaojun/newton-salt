keystone-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }} 
       - tgt_type: list
       - sls:
         - dev.openstack.keystone
       - require:
         - salt: memcache-init
         - salt: rabbitmq-init
         - salt: mariadb-init
         - salt: mongodb-init
{% if salt['pillar.get']('config_logstash_install',False) %}
         - salt: elasticsearch-init
{% endif %}
{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED',True) %}
         - salt: influxdb-init
{% endif %}

keystone-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:mariadb:MASTER') }} 
       - sls:
         - dev.openstack.keystone.db
       - require: 
         - salt: keystone-init
         - salt: galera-cluster-init

keystone-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.keystone.service
       - require:
         - salt: keystone-db-init

keystone-user-role-tenant-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
       - sls:
         - dev.openstack.keystone.user-role-tenant
       - require:
         - salt: keystone-service

keystone-add-haproxy:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.keystone.keystone-haproxy
       - require:
         - salt: keystone-service 
{% if salt['pillar.get']('haproxy:ENABLE_KEEPALIVED') %}
         - salt: haproxy-service
{% else %}
         - salt: crm-haproxy
{% endif %}
