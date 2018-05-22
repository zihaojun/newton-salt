ceilometer-compute:
  pkg.installed:
    - pkgs:
      - openstack-ceilometer-compute

/etc/ceilometer/ceilometer.conf:
  file.managed:
    - source: salt://dev/compute/ceilometer/templates/ceilometer.conf.template
    - template: jinja
    - default:
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      CEILOMETER_USER_PASS: {{ salt['pillar.get']('public_password') }}
    - require:
      - pkg: ceilometer-compute

ceilometer-compute-service:
  cmd.script:
    - source: salt://dev/compute/ceilometer/templates/ceilometer-compute-service.sh
    - require:
      - file: /etc/ceilometer/ceilometer.conf
