keystone-database:
  mysql_database.present:
    - name: 'keystone'
    - connection_user: root
    - connection_pass: 'openstack'

{% for host in ['localhost','%'] %}
mysql-keystone-{{ host }}-grants:
  mysql_user.present:
    - name: 'keystone'
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('public_password') }}"
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: keystone-database
  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - host: '{{ host }}'
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: keystone-database
      - mysql_user: mysql-keystone-{{ host }}-grants
{% endfor %}
