zabbix-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.zabbix.lamp

zabbix:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.zabbix.zabbix_server
      - dev.zabbix.zabbix_agent
    - require:
      - salt: zabbix-init
