zabbix-agent:
  pkg.installed:
    - pkgs:
      - zabbix-agent
/etc/zabbix/zabbix_agentd.conf:
  file.managed:
    - source: salt://dev/monitor/zabbix/files/zabbix_agentd.conf
    - template: jinja
    - default:
    {% if salt['pillar.get']('compute:ENABLED') %}
    - ZABBIX_IP: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
    {% else %}
    - ZABBIX_IP: 127.0.0.1
    {% endif %}
    - user: root
    - group: root
    - mode: 644

agent-service:
  cmd.run:
    - name: systemctl enable zabbix-agent && systemctl start zabbix-agent
    - require:
      - pkg: zabbix-agent
      - file: /etc/zabbix/zabbix_agentd.conf

