nova-compute:
  pkg.installed:
    - pkgs:
      - openstack-nova-compute

/etc/nova/nova.conf:
  file.managed:
    - source: salt://dev/compute/nova/templates/nova.conf.template
    - template: jinja
    - default:
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      NOVA_USER_PASS: {{ salt['pillar.get']('public_password') }}
      COMPUTE_IP: {{ salt['pillar.get']('compute:COMPUTE_IP') }}
      PUBLIC_ADDR: {{ salt['pillar.get']('nova:PUBLIC_ADDR') }}
    - require:
      - pkg: nova-compute

nova-compute-service:
  cmd.script:
    - source: salt://dev/compute/nova/templates/nova-compute-service.sh
    - require:
      - file: /etc/nova/nova.conf
