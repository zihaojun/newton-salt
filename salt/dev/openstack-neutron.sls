neutron-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.openstack.neutron
