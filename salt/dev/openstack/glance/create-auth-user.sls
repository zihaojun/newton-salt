auth-user-glance:
  cmd.script:
    - source: salt://dev/openstack/glance/templates/create-user.sh
    - template: jinja
    - default:
      GLANCE_USER_PASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
