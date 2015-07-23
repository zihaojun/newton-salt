mysql-neutron-database:
  mysql_database.present:
    - name: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_DBNAME','neutron') }} 
    - connection_user: root
    - connection_pass: ''

{% for host in ['localhost','%'] %}
mysql-neutron-{{ host }}-grants:
  mysql_user.present:
    - name: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_USER','neutron') }}
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('neutron:MYSQL_NEUTRON_PASS','neutron') }}"
    - connection_user: root
    - connection_pass: ''
    - require:
      - mysql_database: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_DBNAME','neutron') }}
  mysql_grants.present:
    - grant: all privileges
    - database: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_DBNAME','neutron') }}.*
    - user: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_USER','neutron') }}
    - host: '{{ host }}'
    - require:
      - mysql_database: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_DBNAME','neutron') }}
      - mysql_user: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_USER','neutron') }}
{% endfor %}

neutron-table-sync:
  cmd.run:
    - name: /usr/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno 
    - require:
      - mysql_grants: mysql-neutron-localhost-grants
      - mysql_grants: mysql-neutron-%-grants
