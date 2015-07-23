mysql-glance-database:
  mysql_database.present:
    - name: {{ salt['pillar.get']('glance:MYSQL_GLANCE_DBNAME','glance') }} 
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-glance-{{ host }}-grants:
  mysql_user.present:
    - name: {{ salt['pillar.get']('glance:MYSQL_GLANCE_USER','glance') }}
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('glance:MYSQL_GLANCE_PASS','glance') }}"
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: {{ salt['pillar.get']('glance:MYSQL_GLANCE_DBNAME','glance') }}
  mysql_grants.present:
    - grant: all privileges
    - database: {{ salt['pillar.get']('glance:MYSQL_GLANCE_DBNAME','glance') }}.*
    - user: {{ salt['pillar.get']('glance:MYSQL_GLANCE_USER','glance') }}
    - host: '{{ host }}'
    - require:
      - mysql_database: {{ salt['pillar.get']('glance:MYSQL_GLANCE_DBNAME','glance') }} 
      - mysql_user: {{ salt['pillar.get']('glance:MYSQL_GLANCE_USER','glance') }}
{% endfor %}

glance-table-sync:
  cmd.run:
    - name: /usr/bin/glance-manage db_sync 
    - require:
      - mysql_grants: mysql-glance-localhost-grants
      - mysql_grants: mysql-glance-%-grants
