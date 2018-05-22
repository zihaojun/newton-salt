include:
  - dev.openstack.neutron.pkg-init

neutron-service:
  cmd.script:
    - source: salt://dev/openstack/neutron/templates/neutron_service.sh
    - require:
      - file: /etc/neutron/plugins/ml2/ml2_conf.ini
      - cmd: neutron-nova
