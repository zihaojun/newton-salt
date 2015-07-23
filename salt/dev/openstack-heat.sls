heat-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.heat

heat-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:mariadb:MASTER') }}
       - sls:
         - dev.openstack.heat.db
       - require:
         - salt: heat-init
         - salt: galera-cluster-init 

heat-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.heat.service
       - require:
         - salt: heat-db-init
{% if salt['pillar.get']('config_ha_install',False) %}
         - salt: keystone-add-haproxy
{% endif %}
