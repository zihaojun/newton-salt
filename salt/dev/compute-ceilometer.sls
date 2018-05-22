compute-ceilometer-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.compute.ceilometer
