neutron-database:
  mysql_database.present:
    - name: 'neutron'
    - connection_user: root
    - connection_pass: 'openstack'

{% for host in ['localhost','%'] %}
mysql-neutron-{{ host }}-grants:
  mysql_user.present:
    - name: 'neutron'
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('public_password') }}"
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: neutron-database
  mysql_grants.present:
    - grant: all privileges
    - database: neutron.*
    - user: neutron
    - host: '{{ host }}'
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: neutron-database
      - mysql_user: mysql-neutron-{{ host }}-grants
{% endfor %}
