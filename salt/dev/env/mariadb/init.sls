include:
  - dev.env.mariadb.db-install

mysql_secure:
  cmd.script:
    - source: salt://dev/env/mariadb/templates/mysql-secure.sh
    - require:
      - cmd: mariadb-service
