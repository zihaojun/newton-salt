mysql-animbus-database:
  mysql_database.present:
    - name: animbus
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-animbus-{{ host }}-grants:
  mysql_user.present:
    - name: animbus
    - host: '{{ host }}'
    - password: animbus
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: animbus
  mysql_grants.present:
    - grant: all privileges
    - database: animbus.*
    - user: animbus
    - host: '{{ host }}'
    - require:
      - mysql_database: animbus
      - mysql_user: animbus
{% endfor %}

animbus-table-sync:
  cmd.run:
    - name:  python /usr/share/openstack-dashboard/manage.py db_sync 
    - require:
      - mysql_grants: mysql-animbus-localhost-grants
      - mysql_grants: mysql-animbus-%-grants
