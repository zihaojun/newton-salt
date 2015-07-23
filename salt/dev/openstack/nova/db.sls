mysql-nova-database:
  mysql_database.present:
    - name: {{ salt['pillar.get']('nova:MYSQL_NOVA_DBNAME','nova') }} 
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-nova-{{ host }}-grants:
  mysql_user.present:
    - name: {{ salt['pillar.get']('nova:MYSQL_NOVA_USER','nova') }}
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('nova:MYSQL_NOVA_PASS','nova') }}"
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: {{ salt['pillar.get']('nova:MYSQL_NOVA_DBNAME','nova') }}
  mysql_grants.present:
    - grant: all privileges
    - database: {{ salt['pillar.get']('nova:MYSQL_NOVA_DBNAME','nova') }}.*
    - user: {{ salt['pillar.get']('nova:MYSQL_NOVA_USER','nova') }}
    - host: '{{ host }}'
    - require:
      - mysql_database: {{ salt['pillar.get']('nova:MYSQL_NOVA_DBNAME','nova') }}
      - mysql_user: {{ salt['pillar.get']('nova:MYSQL_NOVA_USER','nova') }}
{% endfor %}

nova-table-sync:
  cmd.run:
    - name: /usr/bin/nova-manage db sync 
    - require:
      - mysql_grants: mysql-nova-localhost-grants
      - mysql_grants: mysql-nova-%-grants
