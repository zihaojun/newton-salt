horizon-init:
   pkg.installed:
     - pkgs:
       - httpd
       - mod_wsgi
       - openstack-dashboard

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

{#
# It applies to origin openstack dashboard.
/etc/httpd/conf.d/openstack-dashboard.conf:
    file.managed:
       - source: salt://dev/openstack/horizon/files/openstack-dashboard.conf
       - mode: 644
       - require:
         - pkg: horizon-init
#}

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
      - file: /etc/openstack-dashboard/animbus_local_settings
{#      - file: /etc/httpd/conf.d/openstack-dashboard.conf #}
      - file: /etc/httpd/conf/httpd.conf
