openstack-cinder:
  service.running:
    - names:
      - openstack-cinder-api
      - openstack-cinder-scheduler
{% if salt['pillar.get']('basic:cinder:BACKENDS') != 'none' %}
      - openstack-cinder-volume
{% endif %}
{% if salt['pillar.get']('basic:cinder:BACKENDS') == 'lvm' %}
      - lvm2-lvmetad
      - target
{% endif %}
    - enable: True
    - watch:
      - file: /etc/cinder/cinder.conf 

/etc/cinder/cinder.conf:
    file.managed:
        - source: salt://dev/openstack/cinder/templates/cinder.conf.template
        - mode: 644
        - user: cinder
        - group: cinder
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
          BACKENDS: {{ salt['pillar.get']('basic:cinder:BACKENDS') }}
          MYSQL_CINDER_USER: {{ salt['pillar.get']('cinder:MYSQL_CINDER_USER') }}
          MYSQL_CINDER_PASS: {{ salt['pillar.get']('cinder:MYSQL_CINDER_PASS') }}
          MYSQL_CINDER_DBNAME: {{ salt['pillar.get']('cinder:MYSQL_CINDER_DBNAME') }}
          AUTH_ADMIN_CINDER_USER: {{ salt['pillar.get']('cinder:AUTH_ADMIN_CINDER_USER') }}
          AUTH_ADMIN_CINDER_PASS: {{ salt['pillar.get']('cinder:AUTH_ADMIN_CINDER_PASS') }}
