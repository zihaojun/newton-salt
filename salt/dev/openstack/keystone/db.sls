mysql-keystone-database:
  mysql_database.present:
    - name: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_DBNAME','keystone') }} 
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-keystone-{{ host }}-grants:
  mysql_user.present:
    - name: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_USER','keystone') }} 
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_PASS','keystone') }}" 
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_DBNAME','keystone') }} 
  mysql_grants.present:
    - grant: all privileges
    - database: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_DBNAME','keystone') }}.*
    - user: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_USER','keystone') }}
    - host: '{{ host }}'
    - require:
      - mysql_database: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_DBNAME','keystone') }} 
      - mysql_user: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_USER','keystone') }} 
{% endfor %}

keystone-table-sync:
  cmd.run:
    - name: /usr/bin/keystone-manage db_sync 
    - require:
      - mysql_grants: mysql-keystone-localhost-grants
      - mysql_grants: mysql-keystone-%-grants
