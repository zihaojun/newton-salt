glance-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.openstack.glance
