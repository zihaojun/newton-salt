mysql-heat-database:
  mysql_database.present:
    - name: heat
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-heat-{{ host }}-grants:
  mysql_user.present:
    - name: heat
    - host: '{{ host }}'
    - password: heat
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: heat
  mysql_grants.present:
    - grant: all privileges
    - database: heat.*
    - user: heat
    - host: '{{ host }}'
    - require:
      - mysql_database: heat
      - mysql_user: heat
{% endfor %}

heat-table-sync:
  cmd.run:
    - name: /usr/bin/heat-manage db_sync 
    - require:
      - mysql_grants: mysql-heat-localhost-grants
      - mysql_grants: mysql-heat-%-grants
