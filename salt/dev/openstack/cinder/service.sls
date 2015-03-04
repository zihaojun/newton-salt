openstack-cinder:
  service.running:
    - names:
      - openstack-cinder-api
      - openstack-cinder-scheduler
    - enable: True
