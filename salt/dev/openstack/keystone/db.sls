mysql-keystone-database:
  mysql_database.present:
    - name: keystone
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-keystone-{{ host }}-grants:
  mysql_user.present:
    - name: keystone
    - host: '{{ host }}'
    - password: keystone
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: keystone
  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - host: '{{ host }}'
    - require:
      - mysql_database: keystone
      - mysql_user: keystone
{% endfor %}

keystone-table-sync:
  cmd.run:
    - name: /usr/bin/keystone-manage db_sync 
    - require:
      - mysql_grants: mysql-keystone-localhost-grants
      - mysql_grants: mysql-keystone-%-grants

