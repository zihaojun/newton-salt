zabbix-server:
  pkg.installed:
    - pkgs:
      - zabbix-server-mysql
      - zabbix-web-mysql
      - zabbix-get

db-set:
  cmd.script:
    - source: salt://dev/monitor/zabbix/files/sql.sh
    - unless: mysql -uzabbix -pzabbix && mysql -uroot -popenstack -e "show databases" | grep zabbix
    - require:
      - pkg: zabbix-server

/etc/zabbix/zabbix_server.conf:
  file.managed:
    - source: salt://dev/monitor/zabbix/files/zabbix_server.conf
    - user: root
    - group: root
    - mode: 644

/etc/php.ini:
  file.managed:
    - source: salt://dev/monitor/zabbix/files/php.ini
    - user: root
    - group: root
    - mode: 644

/etc/httpd/conf.d/zabbix.conf:
  file.managed:
    - source: salt://dev/monitor/zabbix/files/zabbix.conf
    - user: root
    - group: root
    - mode: 644

server-service:
  cmd.run:
    - name: systemctl enable zabbix-server && systemctl start zabbix-server && systemctl restart httpd
    - require:
      - file: /etc/zabbix/zabbix_server.conf
      - cmd: db-set

