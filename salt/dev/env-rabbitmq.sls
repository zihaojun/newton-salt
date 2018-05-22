rabbitmq-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.env.rabbitmq
    - require:
      - salt: mariadb-init
