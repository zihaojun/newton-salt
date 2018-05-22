keystone-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.openstack.keystone
