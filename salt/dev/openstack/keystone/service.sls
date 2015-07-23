{% if salt['pillar.get']('keystone:ENABLE_HTTPD_WSGI',True) %}
httpd:
  service.running:
    - enable: True
    - watch:
      - file: /etc/httpd/conf.d/wsgi-keystone.conf 
      - file: /etc/keystone/keystone.conf

/etc/httpd/conf.d/wsgi-keystone.conf:
  file.managed:
    - source: salt://dev/openstack/keystone/templates/wsgi-keystone.conf.template
    - template: jinja
    - defaults:
      IPADDR: {{ grains['host'] }}

{% else %}
openstack-keystone:
  service.running:
    - enable: True
    - watch:
      - file: /etc/keystone/keystone.conf 
{% endif %}

/etc/keystone/keystone.conf:
   file.managed:
      - source: salt://dev/openstack/keystone/templates/keystone.conf.template
      - mode: 640
      - user: keystone
      - group: keystone
      - template: jinja
      - defaults:
        ADMIN_TOKEN: {{ salt['pillar.get']('keystone:ADMIN_TOKEN') }}
        IPADDR: {{ grains['host'] }}
{% if salt['pillar.get']('config_ha_install',False) %}
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
{% else %}
        VIP: {{ grains['host'] }}
{% endif %}
        MYSQL_KEYSTONE_USER: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_USER') }}
        MYSQL_KEYSTONE_PASS: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_PASS') }}
        MYSQL_KEYSTONE_DBNAME: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_DBNAME') }}
        TOKEN_TYPE:  {{ salt['pillar.get']('keystone:TOKEN_TYPE','uuid') }}

