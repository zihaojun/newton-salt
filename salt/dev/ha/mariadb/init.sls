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

/var/log/mariadb:
   file.directory:
      - dir_mode: 755
      - file_mode: 644
      - user: mysql
      - group: mysql
      - recurse:
        - user
        - group
        - mode
      - require:
        - pkg: mariadb-galera-10.0

mariadb:
   service.running:
      - name: mysql 
      - enable: True
      - watch:
        - pkg: mariadb-galera-10.0
        - file: /var/log/mariadb
