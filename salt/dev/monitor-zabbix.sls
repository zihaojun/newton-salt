zabbix-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.monitor.zabbix
