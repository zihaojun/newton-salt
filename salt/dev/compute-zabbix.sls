compute-zabbix-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.compute.zabbix
