compute-neutron-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.compute.neutron
