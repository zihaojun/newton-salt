mysql-glance-database:
  mysql_database.present:
    - name: glance
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-glance-{{ host }}-grants:
  mysql_user.present:
    - name: glance
    - host: '{{ host }}'
    - password: glance
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: glance
  mysql_grants.present:
    - grant: all privileges
    - database: glance.*
    - user: glance
    - host: '{{ host }}'
    - require:
      - mysql_database: glance
      - mysql_user: glance
{% endfor %}

glance-table-sync:
  cmd.run:
    - name: /usr/bin/glance-manage db_sync 
    - require:
      - mysql_grants: mysql-glance-localhost-grants
      - mysql_grants: mysql-glance-%-grants
