mysql-nova-database:
  mysql_database.present:
    - name: nova
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-nova-{{ host }}-grants:
  mysql_user.present:
    - name: nova
    - host: '{{ host }}'
    - password: nova
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: nova
  mysql_grants.present:
    - grant: all privileges
    - database: nova.*
    - user: nova
    - host: '{{ host }}'
    - require:
      - mysql_database: nova
      - mysql_user: nova
{% endfor %}

nova-table-sync:
  cmd.run:
    - name: /usr/bin/nova-manage db sync 
    - require:
      - mysql_grants: mysql-nova-localhost-grants
      - mysql_grants: mysql-nova-%-grants
