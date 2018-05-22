glustermon-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.monitor.glustermon
