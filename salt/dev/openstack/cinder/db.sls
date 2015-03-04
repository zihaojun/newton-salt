mysql-cinder-database:
  mysql_database.present:
    - name: cinder
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-cinder-{{ host }}-grants:
  mysql_user.present:
    - name: cinder
    - host: '{{ host }}'
    - password: cinder
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: cinder
  mysql_grants.present:
    - grant: all privileges
    - database: cinder.*
    - user: cinder
    - host: '{{ host }}'
    - require:
      - mysql_database: cinder
      - mysql_user: cinder
{% endfor %}

cinder-table-sync:
  cmd.run:
    - name: /usr/bin/cinder-manage db sync 
    - require:
      - mysql_grants: mysql-cinder-localhost-grants
      - mysql_grants: mysql-cinder-%-grants
