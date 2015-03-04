openstack-ceilometer:
  service.running:
    - names:
      - snmpd
      - openstack-ceilometer-api
      - openstack-ceilometer-central
      - openstack-ceilometer-collector
      - openstack-ceilometer-notification
    - enable: True
