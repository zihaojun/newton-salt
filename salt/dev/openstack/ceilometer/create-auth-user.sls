auth-user-ceilometer:
  cmd.script:
    - source: salt://dev/openstack/ceilometer/templates/create-user.sh
    - template: jinja
    - default:
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      CEILOMETER_USER_PASS: {{ salt['pillar.get']('public_password') }}
      CEILOMETER_DBPASS: {{ salt['pillar.get']('public_password') }}
    - require:
      - service: service-init
