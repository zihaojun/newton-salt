{% for dbname in ['nova_api','nova'] %}
{{ dbname }}-database:
  mysql_database.present:
    - name: '{{ dbname }}'
    - connection_user: root
    - connection_pass: 'openstack'
  {% for host in ['localhost','%'] %}
mysql-{{dbname}}-{{ host }}-grants:
  mysql_user.present:
    - name: 'nova'
    - host: '{{ host }}'
    - password: "{{ salt['pillar.get']('public_password') }}"
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: {{ dbname }}-database
  mysql_grants.present:
    - grant: all privileges
    - database: {{ dbname }}.*
    - user: nova
    - host: '{{ host }}'
    - connection_user: root
    - connection_pass: 'openstack'
    - require:
      - mysql_database: {{ dbname }}-database
      - mysql_user: mysql-{{ dbname }}-{{ host }}-grants
  {% endfor %}
{% endfor %}

