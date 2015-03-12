{% if not salt['mysql.user_exists'](pillar['mariadb'].get('SST_USER')) %}
{% for host in ['localhost','%'] %}
mariadb-sst-{{ host }}-grants:
  mysql_user.present:
    - name: {{ pillar['mariadb'].get('SST_USER') }}
    - host: '{{ host }}'
    - password: {{ pillar['mariadb'].get('SST_PASS') }}
    - connection_user: root
    - connection_pass: ''
  mysql_grants.present:
    - grant: all privileges
    - database: \*.*
    - user: {{ pillar['mariadb'].get('SST_USER') }}
    - host: '{{ host }}'
    - require:
      - mysql_user: {{ pillar['mariadb'].get('SST_USER') }} 
{% endfor %}
{% else %}
mariadb-sst-user-created:
  cmd.run:
     - name: echo 'mariadb sst user has been created'
{% endif %}
