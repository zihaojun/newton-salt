openstack-glance:
  service.running:
    - names:
      - openstack-glance-api
      - openstack-glance-registry
    - enable: True
