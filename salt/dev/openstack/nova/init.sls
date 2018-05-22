include:
  - dev.openstack.nova.db
  - dev.openstack.nova.create-auth-user

nova:
  pkg.installed:
    - pkgs:
      - openstack-nova-api
      - openstack-nova-conductor
      - openstack-nova-console
      - openstack-nova-novncproxy
      - openstack-nova-scheduler
      - openstack-nova-compute

/etc/nova/nova.conf:
  file.managed:
    - source: salt://dev/openstack/nova/templates/nova.conf.template
    - template: jinja
    - default:
      NOVA_USER_PASS: {{ salt['pillar.get']('public_password') }}
      NOVA_DBPASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      CONTROLLER_IP: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
      PLACEMENT_USER_PASS: {{ salt['pillar.get']('public_password') }}
      PUBLIC_ADDR: {{ salt['pillar.get']('nova:PUBLIC_ADDR') }}
    - require:
      - pkg: nova

nova-service:
  cmd.script:
    - source: salt://dev/openstack/nova/templates/nova-service.sh
    - require:
      - file: /etc/nova/nova.conf
      - mysql_database: nova-database
