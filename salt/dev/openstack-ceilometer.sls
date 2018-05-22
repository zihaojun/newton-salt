ceilometer-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.openstack.ceilometer
