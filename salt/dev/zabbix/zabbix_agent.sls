zabbix-agent:
  pkg.installed:
    - pkgs:   
      - zabbix-agent
/etc/zabbix/zabbix_agentd.conf:
  file.managed:
    - source: salt://dev/zabbix/files/zabbix_agentd.conf
    - template: jinja
    - default:
      ZABBIX_IP: 127.0.0.1
    - user: root
    - group: root
    - mode: 644

agent-service:
  cmd.run:
    - name: systemctl enable zabbix-agent && systemctl start zabbix-agent
    - require:
      - pkg: zabbix-agent
      - file: /etc/zabbix/zabbix_agentd.conf
