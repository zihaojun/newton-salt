auth-user-cinder:
  cmd.script:
    - source: salt://dev/openstack/cinder/templates/create-user.sh
    - template: jinja
    - default:
      CINDER_USER_PASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
