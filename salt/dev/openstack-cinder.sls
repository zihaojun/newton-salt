cinder-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.openstack.cinder
