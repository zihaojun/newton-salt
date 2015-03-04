base:
   '*':
{% if pillar['config']['COMMON'].get('NODE_TYPE') == 'compute' %}
     - openstack.ntp.compute
     - openstack.glusterfs.compute
     - openstack.init.compute_base
     - openstack.nova.compute
     - openstack.neutron.compute
     - openstack.ceilometer.compute
{% elif pillar['config']['COMMON'].get('NODE_TYPE') == 'controller' %}
     - openstack.hosts.controller
     - openstack.ntp.controller
     - openstack.glusterfs.controller
     - openstack.rabbitmq.controller
     - openstack.mysql.controller
     - openstack.keystone.controller
     - openstack.glance.controller
     - openstack.nova.controller
     - openstack.neutron.controller
     - openstack.cinder.controller
     - openstack.ceilometer.controller
     - openstack.horizon.controller

{% elif pillar['config']['COMMON'].get('NODE_TYPE') == 'deploy' %}
{% if pillar['config']['DEPLOY']['DNSMASQ_ENABLED'] %}
     - openstack.deploy.dnsmasq
{% else %}
     - openstack.deploy
{% endif %}

{% elif pillar['config']['COMMON'].get('NODE_TYPE') == 'storage' %}

{% endif %}
