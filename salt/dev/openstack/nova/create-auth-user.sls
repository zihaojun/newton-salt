auth-user-nova:
  cmd.script:
    - source: salt://dev/openstack/nova/templates/create-user.sh
    - template: jinja
    - default:
      NOVA_USER_PASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      PLACEMENT_USER_PASS: {{ salt['pillar.get']('public_password') }}
