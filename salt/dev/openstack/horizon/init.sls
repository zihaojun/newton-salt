{% set horizon_version = salt['cmd.run']("yum list | awk '/openstack-dashboard/ {for(i=1;i<=NF;i++) if($i ~ /(v3.1)/)  print $i }'") %}
horizon-init:
   pkg.installed:
     - pkgs:
       - httpd
       - mod_wsgi
{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED') %}
       - python-influxdb 
       - python-django-horizon: {{ horizon_version }}
       - openstack-dashboard: {{ horizon_version }}
{% else %}
       - python-django-horizon: 2014.2.2-1.el7
       - openstack-dashboard: 2014.2.2-1.el7
{% endif %}

/etc/openstack-dashboard/local_settings:
    file.managed:
       - source: salt://dev/openstack/horizon/templates/local_settings.template
       - mode: 640
       - user: apache
       - group: apache
       - template: jinja
       - defaults:
         IPADDR: {{ grains['host'] }}
{% if salt['pillar.get']('config_ha_install',False) %}
         VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
{% else %}
         VIP: {{ grains['host'] }}
{% endif %}
       - require:
         - pkg: horizon-init

{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED') %}
/etc/openstack-dashboard/animbus_local_settings:
    file.managed:
       - source: salt://dev/openstack/horizon/templates/animbus_local_settings.template
       - mode: 640
       - user: apache
       - group: apache
       - template: jinja
       - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
         VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
         INFLUXDB_PORT: {{ '8087' }}
{% else %}
         VIP: {{ grains['host'] }}
         INFLUXDB_PORT: {{ '8086' }}
{% endif %}
         INFLUXDB_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:INFLUXDB_CEILOMETER_USER') }} 
         INFLUXDB_CEILOMETER_PASS: {{ salt['pillar.get']('ceilometer:INFLUXDB_CEILOMETER_PASS') }}
         INFLUXDB_CEILOMETER_DBNAME: {{ salt['pillar.get']('ceilometer:INFLUXDB_CEILOMETER_DBNAME') }}
         ADMIN_USER: {{ salt['pillar.get']('keystone:ADMIN_USER') }}
         ADMIN_PASS: {{ salt['pillar.get']('keystone:ADMIN_PASS') }}
       - require:
         - pkg: horizon-init
{% else %}
/etc/httpd/conf.d/openstack-dashboard.conf:
    file.managed:
       - source: salt://dev/openstack/horizon/files/openstack-dashboard.conf
       - mode: 644
       - require:
         - pkg: horizon-init
{% endif %}

/etc/httpd/conf/httpd.conf:
    file.managed:
       - source: salt://dev/openstack/horizon/templates/httpd.conf.template
       - mode: 644
       - template: jinja
       - defaults:
         HOSTNAME: {{ grains['host'] }}
       - require:
         - pkg: horizon-init

/tmp/openstack-post.sh:
    file.managed:
       - source: salt://dev/openstack/horizon/files/openstack-post.sh
       - mode: 755


/etc/httpd/conf.modules.d/00-deflate.conf:
    file.managed:
       - source: salt://dev/openstack/horizon/files/00-deflate.conf
       - mode: 644

httpd:
  service.running:
    - enable: True
    - watch:
      - file: /etc/openstack-dashboard/local_settings
      - file: /etc/httpd/conf.modules.d/00-deflate.conf
{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED') %}
      - file: /etc/openstack-dashboard/animbus_local_settings
{% else %}
      - file: /etc/httpd/conf.d/openstack-dashboard.conf
{% endif %}
      - file: /etc/httpd/conf/httpd.conf
