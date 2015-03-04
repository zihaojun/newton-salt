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
       - require:
         - pkg: horizon-init

/etc/httpd/conf/httpd.conf:
    file.replace:
       - pattern: Listen 80
       - repl: Listen {{ grains['host'] }}:80
       - require:
         - pkg: horizon-init

/etc/httpd/conf.d/openstack-dashboard.conf:
    file.managed:
       - source: salt://dev/openstack/horizon/files/openstack-dashboard.conf
       - mode: 644
       - require:
         - pkg: horizon-init

httpd:
  service.running:
    - enable: True
    - watch:
      - file: /etc/openstack-dashboard/local_settings
      - file: /etc/httpd/conf.d/openstack-dashboard.conf
      - file: /etc/httpd/conf/httpd.conf
