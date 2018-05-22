cinder-database:
  mysql_database.present:
    - name: 'cinder'
    - connection_user: root
    - connection_pass: 'openstack'

{% for host in ['localhost','%'] %}
mysql-cinder-{{ host }}-grants:
  mysql_user.present:
    - name: 'cinder'
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('public_password') }}"
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: cinder-database
  mysql_grants.present:
    - grant: all privileges
    - database: cinder.*
    - user: cinder
    - host: '{{ host }}'
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: cinder-database
      - mysql_user: mysql-cinder-{{ host }}-grants
{% endfor %}
