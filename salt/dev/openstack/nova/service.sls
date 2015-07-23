openstack-nova:
  service.running:
    - names:
      - openstack-nova-api
      - openstack-nova-cert
      - openstack-nova-conductor
      - openstack-nova-consoleauth
      - openstack-nova-scheduler
{% if salt['pillar.get']('nova:VNC_ENABLED') %}
      - openstack-nova-novncproxy
{% else %}
      - openstack-nova-spicehtml5proxy
{% endif %}
    - enable: True
    - watch:
      - file: /etc/nova/nova.conf

{% if salt['pillar.get']('basic:nova:CONTROLLER:COMPUTE_ENABLED',False) %}
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
        - service: openstack-nova
{% endif %}

/etc/nova/nova.conf:
   file.managed:
        - source: salt://dev/openstack/nova/templates/nova.conf.controller.template
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
{% if not salt['pillar.get']('basic:nova:CONTROLLER:COMPUTE_ENABLED',False) %}
          VIP: {{ grains['host'] }}
{% else %}
{% set HOSTNAME = grains['host'] %}
{% set CONTROLLER_HOSTS = salt['pillar.get']('basic:nova:CONTROLLER:HOSTS') %}
          VIP: {{ CONTROLLER_HOSTS.get(HOSTNAME,'') }}
          RABBIT: {{ grains['host'] + ':5672' }}
{% endif %}
{% endif %}
          RABBIT_USER: {{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}
          RABBIT_PASS: {{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}
          VNC_ENABLED: {{ salt['pillar.get']('nova:VNC_ENABLED') }}
          COMPUTE_ENABLED: {{ salt['pillar.get']('basic:nova:CONTROLLER:COMPUTE_ENABLED',False) }}
          MYSQL_NOVA_USER: {{ salt['pillar.get']('nova:MYSQL_NOVA_USER') }}
          MYSQL_NOVA_PASS: {{ salt['pillar.get']('nova:MYSQL_NOVA_PASS') }}
          MYSQL_NOVA_DBNAME: {{ salt['pillar.get']('nova:MYSQL_NOVA_DBNAME') }}
          AUTH_ADMIN_NOVA_USER: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_USER') }}
          AUTH_ADMIN_NOVA_PASS: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_PASS') }}
          METADATA_PROXY_SECRET: {{ salt['pillar.get']('nova:METADATA_PROXY_SECRET') }}
          AUTH_ADMIN_NEUTRON_USER: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_USER') }}
          AUTH_ADMIN_NEUTRON_PASS: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_PASS') }}
