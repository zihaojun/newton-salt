ntp-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.env.ntp
