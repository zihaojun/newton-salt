nova-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.openstack.nova
