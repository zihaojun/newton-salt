compute-elkf-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.compute.elkf
