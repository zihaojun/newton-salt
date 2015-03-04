{% if salt['pillar.get']('mariadb:VERSION') == '5.5' %}
mariadb:
   pkg.installed:
      - pkgs:
         - mariadb-galera-server
         - mariadb
         - mariadb-libs
         - MySQL-python
         - rsync
   service.running:
      - enable: True
      - require:
        - pkg: mariadb

{% endif %}

remvoe-mariadb-libs:
   cmd.run:
      - name: rpm -e mariadb-libs --nodeps
      - onlyif: rpm -q mariadb-libs

mariadb-galera-10.0:
   pkg.installed:
      - pkgs:
         - MariaDB-common
         - MariaDB-shared
         - MariaDB-client
         - MariaDB-Galera-server
         - MySQL-python
         - rsync 
      - require:
        - cmd: remvoe-mariadb-libs

mariadb:
   service.running:
      - name: mysql 
      - enable: True
      - watch:
        - pkg: mariadb-galera-10.0

{% if not salt['mysql.user_exists'](pillar['mariadb'].get('SST_USER')) %}
{% for host in ['localhost','%'] %}
mariadb-sst-{{ host }}-grants:
  mysql_user.present:
    - name: {{ pillar['mariadb'].get('SST_USER') }}
    - host: '{{ host }}'
    - password: {{ pillar['mariadb'].get('SST_PASS') }}
    - connection_user: root
    - connection_pass: ''
    - require:
      - service: mariadb
  mysql_grants.present:
    - grant: all privileges
    - database: \*.*
    - user: {{ pillar['mariadb'].get('SST_USER') }}
    - host: '{{ host }}'
    - require:
      - mysql_user: {{ pillar['mariadb'].get('SST_USER') }} 
{% endfor %}
{% endif %}
