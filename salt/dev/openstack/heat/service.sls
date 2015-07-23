openstack-heat:
  service.running:
    - names:
      - openstack-heat-api
      - openstack-heat-engine
    - enable: True
    - watch:
      - file: /etc/heat/heat.conf

/etc/heat/heat.conf:
   file.managed:
        - source: salt://dev/openstack/heat/templates/heat.conf.template
        - mode: 644
        - user: heat
        - group: heat
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_2') + ':5672,' + salt['pillar.get']('basic:corosync:NODE_1') + ':5672' }}
{% else %}
          VIP: {{ grains['host'] }}
          RABBIT: {{ grains['host'] + ':5672' }}
{% endif %}
          RABBIT_USER: {{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}
          RABBIT_PASS: {{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}
          MYSQL_HEAT_USER: {{ salt['pillar.get']('heat:MYSQL_HEAT_USER') }}
          MYSQL_HEAT_PASS: {{ salt['pillar.get']('heat:MYSQL_HEAT_PASS') }}
          MYSQL_HEAT_DBNAME: {{ salt['pillar.get']('heat:MYSQL_HEAT_DBNAME') }}
          AUTH_ADMIN_HEAT_USER: {{ salt['pillar.get']('heat:AUTH_ADMIN_HEAT_USER') }}
          AUTH_ADMIN_HEAT_PASS: {{ salt['pillar.get']('heat:AUTH_ADMIN_HEAT_PASS') }}

