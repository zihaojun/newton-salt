auth-user-neutron:
  cmd.script:
    - source: salt://dev/openstack/neutron/templates/create-user.sh
    - template: jinja
    - default:
      NEUTRON_USER_PASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
