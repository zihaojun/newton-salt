neutron-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.neutron
       - require:
         - salt: galera-cluster-init

neutron-db-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:mariadb:MASTER') }}
       - sls:
         - dev.openstack.neutron.db
       - require:
         - salt: neutron-init

neutron-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.neutron.service
       - require:
         - salt: neutron-db-init
{% if salt['pillar.get']('config_ha_install',False) %}
         - salt: keystone-add-haproxy
{% endif %}
