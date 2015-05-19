horizon-init:
   pkg.installed:
     - pkgs:
       - httpd
       - mod_wsgi
{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED') %}
       - openstack-dashboard: 2014.2.3.99cloud-1.el7.centos 
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
         VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
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
         VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }} 
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
