horizon-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.horizon

openstack-add-haproxy:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.horizon.openstack-haproxy
       - require:
         - salt: horizon-init
         - salt: glance-service
         - salt: nova-service
         - salt: neutron-service
{% if salt['pillar.get']('config_cinder_install',False) %}
         - salt: cinder-service
{% endif %}
{% if salt['pillar.get']('config_ceilometer_install',False) %}
         - salt: ceilometer-service
{% endif %}
{% if salt['pillar.get']('config_heat_install',False) %}
         - salt: heat-service 
{% endif %}
{% if salt['pillar.get']('config_logstash_install',False) %}
         - salt: logstash-service
{% endif %}
