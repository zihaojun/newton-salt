dashboard-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.openstack.dashboard
