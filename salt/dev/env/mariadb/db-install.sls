mariadb:
  pkg.installed:
    - pkgs:
      - mariadb
      - mariadb-server
      - python2-PyMySQL

/usr/lib/systemd/system/mariadb.service:
  file.managed:
    - source: salt://dev/env/mariadb/templates/mariadb.service
    - require:
      - pkg: mariadb

mariadb-service:
  file.managed:
    - name: /etc/my.cnf.d/openstack.cnf
    - source: salt://dev/env/mariadb/templates/openstack.cnf.template
    - template: jinja
    - default:
      BIND_ADDR: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
    - require:
      - file: /usr/lib/systemd/system/mariadb.service
  cmd.run:
    - name: systemctl enable mariadb.service && systemctl start mariadb.service
    - unless: systemctl list-dependencies | grep mariadb
    - require:
      - file: mariadb-service 
