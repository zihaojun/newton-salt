openstack-glance:
  service.running:
    - names:
      - openstack-glance-api
      - openstack-glance-registry
    - enable: True
    - watch:
      - file: /etc/glance/glance-api.conf
      - file: /etc/glance/glance-registry.conf

{% for srv in ['api','registry'] %}
/etc/glance/glance-{{ srv }}.conf:
    file.managed:
        - source: salt://dev/openstack/glance/templates/glance-{{ srv }}.conf.template
        - mode: 644
        - user: glance
        - group: glance
        - template: jinja
        - defaults:
          AUTH_ADMIN_GLANCE_USER: {{ salt['pillar.get']('glance:AUTH_ADMIN_GLANCE_USER') }}
          AUTH_ADMIN_GLANCE_PASS: {{ salt['pillar.get']('glance:AUTH_ADMIN_GLANCE_PASS') }}
          IPADDR: {{ grains['host'] }}
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_1') + ':5672,' + salt['pillar.get']('basic:corosync:NODE_2') + ':5672' }}
{% else %}
          VIP: {{ grains['host'] }}
          RABBIT: {{ grains['host'] + ':5672' }}
{% endif %}
          RABBIT_USER: {{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}
          RABBIT_PASS: {{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}
          MYSQL_GLANCE_USER: {{ salt['pillar.get']('glance:MYSQL_GLANCE_USER') }}
          MYSQL_GLANCE_PASS: {{ salt['pillar.get']('glance:MYSQL_GLANCE_PASS') }}
          MYSQL_GLANCE_DBNAME: {{ salt['pillar.get']('glance:MYSQL_GLANCE_DBNAME') }}
{% endfor %}
