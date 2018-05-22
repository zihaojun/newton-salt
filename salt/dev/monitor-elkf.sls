elkf-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.monitor.elkf
