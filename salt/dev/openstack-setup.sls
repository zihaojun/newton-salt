include:
   - dev.openstack-hosts
   - dev.ha-ntp
{% if salt['pillar.get']('config_storage_install',True) %}
   - dev.openstack-storage
{% endif %}
{% if not salt['pillar.get']('basic:nova:COMPUTE:ADD_NODE_ENABLED',True) %}
   - dev.ha-memcache
   - dev.ha-rabbitmq
   - dev.ha-mariadb
{% if salt['pillar.get']('config_ceilometer_install',False) %}
   - dev.ha-mongodb
{% endif %}
{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED',True) %}
   - dev.ha-influxdb
{% endif %}
{% if salt['pillar.get']('config_logstash_install',False) %}
   - dev.ha-elasticsearch
{% endif %}
{% if salt['pillar.get']('config_ha_install',False) %}
   - dev.ha-corosync-pacemaker
   - dev.ha-haproxy-keepalived
{% endif %}
   - dev.openstack-keystone
   - dev.openstack-glance
   - dev.openstack-nova
   - dev.openstack-neutron
{% if salt['pillar.get']('config_cinder_install',False) %}
   - dev.openstack-cinder
{% endif %}
{% if salt['pillar.get']('config_ceilometer_install',False) %}
   - dev.openstack-ceilometer
{% endif %}
{% if salt['pillar.get']('config_heat_install',False) %}
   - dev.openstack-heat
{% endif %}
{% if salt['pillar.get']('config_logstash_install',False) %}
   - dev.openstack-logstash
{% endif %}
   - dev.openstack-horizon
{% endif %}
{% if salt['pillar.get']('config_compute_install',False) %}
   - dev.openstack-nova-compute
   - dev.openstack-neutron-compute
{% if salt['pillar.get']('config_ceilometer_install',False) %}
   - dev.openstack-ceilometer-compute
{% endif %}
{% if salt['pillar.get']('config_logstash_install',False) %}
   - dev.openstack-logstash-compute
{% endif %}
{% endif %}
{% if salt['pillar.get']('config_enable_iptables',False) %}
   - dev.openstack-iptables
{% endif %}
{% if salt['pillar.get']('config_enable_os_security',False) %}
   - dev.openstack-os-security
{% endif %}
