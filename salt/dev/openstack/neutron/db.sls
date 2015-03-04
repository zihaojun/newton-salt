mysql-neutron-database:
  mysql_database.present:
    - name: neutron
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-neutron-{{ host }}-grants:
  mysql_user.present:
    - name: neutron
    - host: '{{ host }}'
    - password: neutron
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: neutron
  mysql_grants.present:
    - grant: all privileges
    - database: neutron.*
    - user: neutron
    - host: '{{ host }}'
    - require:
      - mysql_database: neutron
      - mysql_user: neutron
{% endfor %}

neutron-table-sync:
  cmd.run:
    - name: /usr/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno 
    - require:
      - mysql_grants: mysql-neutron-localhost-grants
      - mysql_grants: mysql-neutron-%-grants
