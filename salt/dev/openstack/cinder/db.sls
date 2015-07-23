mysql-cinder-database:
  mysql_database.present:
    - name: {{ salt['pillar.get']('cinder:MYSQL_CINDER_DBNAME','cinder') }} 
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-cinder-{{ host }}-grants:
  mysql_user.present:
    - name: {{ salt['pillar.get']('cinder:MYSQL_CINDER_USER','cinder') }}
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('cinder:MYSQL_CINDER_PASS','cinder') }}"
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: {{ salt['pillar.get']('cinder:MYSQL_CINDER_DBNAME','cinder') }}
  mysql_grants.present:
    - grant: all privileges
    - database: {{ salt['pillar.get']('cinder:MYSQL_CINDER_DBNAME','cinder') }}.*
    - user: {{ salt['pillar.get']('cinder:MYSQL_CINDER_USER','cinder') }}
    - host: '{{ host }}'
    - require:
      - mysql_database: {{ salt['pillar.get']('cinder:MYSQL_CINDER_DBNAME','cinder') }}
      - mysql_user: {{ salt['pillar.get']('cinder:MYSQL_CINDER_USER','cinder') }}
{% endfor %}

cinder-table-sync:
  cmd.run:
    - name: /usr/bin/cinder-manage db sync 
    - require:
      - mysql_grants: mysql-cinder-localhost-grants
      - mysql_grants: mysql-cinder-%-grants
