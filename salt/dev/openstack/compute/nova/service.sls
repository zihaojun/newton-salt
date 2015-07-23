libvirtd:
   service.running:
      - enable: True
      - watch:
        - service: messagebus

messagebus:
   service.running:
      - enable: True

openstack-nova-compute:
   service.running:
      - enable: True
      - watch:
        - service: libvirtd 
        - file: /etc/nova/nova.conf

crond:
   service.running:
      - enable: True

/etc/nova/nova.conf:
   file.managed:
        - source: salt://dev/openstack/compute/nova/templates/nova.conf.compute.template
        - mode: 644
        - user: nova
        - group: nova
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP') }}
          RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_2') + ':5672,' + salt['pillar.get']('basic:corosync:NODE_1') + ':5672' }}
{% else %}
{% set NODE_1 = salt['pillar.get']('basic:corosync:NODE_1') %}
{% set CONTROLLER_HOSTS = salt['pillar.get']('basic:nova:CONTROLLER:HOSTS') %}
          VIP: {{ CONTROLLER_HOSTS.get(NODE_1,'') }}
          RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_1') + ':5672' }}
{% endif %}
          RABBIT_USER: {{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}
          RABBIT_PASS: {{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}
          VNC_ENABLED: {{ salt['pillar.get']('nova:VNC_ENABLED') }}
          MYSQL_NOVA_USER: {{ salt['pillar.get']('nova:MYSQL_NOVA_USER') }}
          MYSQL_NOVA_PASS: {{ salt['pillar.get']('nova:MYSQL_NOVA_PASS') }}
          MYSQL_NOVA_DBNAME: {{ salt['pillar.get']('nova:MYSQL_NOVA_DBNAME') }}
          AUTH_ADMIN_NOVA_USER: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_USER') }}
          AUTH_ADMIN_NOVA_PASS: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_PASS') }}
          METADATA_PROXY_SECRET: {{ salt['pillar.get']('nova:METADATA_PROXY_SECRET') }}
          AUTH_ADMIN_NEUTRON_USER: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_USER') }}
          AUTH_ADMIN_NEUTRON_PASS: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_PASS') }}
