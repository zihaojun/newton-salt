hosts-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.env.hosts
