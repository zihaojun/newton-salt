mysql-heat-database:
  mysql_database.present:
    - name: {{ salt['pillar.get']('heat:MYSQL_HEAT_DBNAME','heat') }} 
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-heat-{{ host }}-grants:
  mysql_user.present:
    - name: {{ salt['pillar.get']('heat:MYSQL_HEAT_USER','heat') }}
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('heat:MYSQL_HEAT_PASS','heat') }}"
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: {{ salt['pillar.get']('heat:MYSQL_HEAT_DBNAME','heat') }}
  mysql_grants.present:
    - grant: all privileges
    - database: {{ salt['pillar.get']('heat:MYSQL_HEAT_DBNAME','heat') }}.*
    - user: {{ salt['pillar.get']('heat:MYSQL_HEAT_USER','heat') }}
    - host: '{{ host }}'
    - require:
      - mysql_database: {{ salt['pillar.get']('heat:MYSQL_HEAT_DBNAME','heat') }}
      - mysql_user: {{ salt['pillar.get']('heat:MYSQL_HEAT_USER','heat') }}
{% endfor %}

heat-table-sync:
  cmd.run:
    - name: /usr/bin/heat-manage db_sync 
    - require:
      - mysql_grants: mysql-heat-localhost-grants
      - mysql_grants: mysql-heat-%-grants
