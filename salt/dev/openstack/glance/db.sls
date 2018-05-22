glance-database:
  mysql_database.present:
    - name: 'glance'
    - connection_user: root
    - connection_pass: 'openstack'

{% for host in ['localhost','%'] %}
mysql-glance-{{ host }}-grants:
  mysql_user.present:
    - name: 'glance'
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('public_password') }}"
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: glance-database
  mysql_grants.present:
    - grant: all privileges
    - database: glance.*
    - user: glance
    - host: '{{ host }}'
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: glance-database
      - mysql_user: mysql-glance-{{ host }}-grants
{% endfor %}
