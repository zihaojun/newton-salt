memc-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.env.memcached
  
