compute-nova-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.compute.nova
