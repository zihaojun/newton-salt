include:
  - dev.openstack.ceilometer.mongo_install
  - dev.openstack.ceilometer.create-auth-user

ceilometer:
  pkg.installed:
    - pkgs:
      - openstack-ceilometer-api
      - openstack-ceilometer-collector
      - openstack-ceilometer-notification
      - openstack-ceilometer-central
      - python2-ceilometerclient
      - openstack-ceilometer-compute

/etc/ceilometer/ceilometer.conf:
  file.managed:
    - source: salt://dev/openstack/ceilometer/templates/ceilometer.conf.template
    - template: jinja
    - default:
      CEILOMETER_DBPASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      RABBIT_PASS: {{ salt['pillar.get']('public_password') }}
      CEILOMETER_USER_PASS: {{ salt['pillar.get']('public_password') }}
    - require:
      - pkg: ceilometer

/etc/httpd/conf.d/wsgi-ceilometer.conf:
  file.managed:
    - source: salt://dev/openstack/ceilometer/templates/wsgi-ceilometer.conf.template
    - require:
      - file: /etc/ceilometer/ceilometer.conf

ceilometer-service:
  cmd.script:
    - source: salt://dev/openstack/ceilometer/templates/ceilometer_service.sh
    - require:
      - file: /etc/httpd/conf.d/wsgi-ceilometer.conf

/var/www/cgi-bin/ceilometer:
  file.directory:
    - user: root
    - group: root
/var/www/cgi-bin/ceilometer/app:
  file.managed:
    - source: salt://dev/openstack/ceilometer/templates/app
    - require:
      - cmd: ceilometer-service
      - file: /var/www/cgi-bin/ceilometer

