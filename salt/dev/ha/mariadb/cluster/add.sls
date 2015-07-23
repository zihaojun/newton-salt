slave-my-cnf:
    file.managed:
       - name: /etc/my.cnf
       - source: salt://dev/ha/mariadb/templates/my.cnf.template
       - mode: 644
       - template: jinja
       - defaults:
         ID: 2
         HOSTNAME: {{ grains['host'] }}
         MASTER: {{ salt['pillar.get']('basic:mariadb:MASTER') }}
         MASTER_ENABLED: False
         SST_USER: {{ pillar['mariadb'].get('SST_USER') }}
         SST_PASS: {{ pillar['mariadb'].get('SST_PASS') }}
    service.running:
       - name: mysql 
       - enable: True
       - watch:
         - file: slave-my-cnf

/etc/init.d/galera:
    file.managed:
       - source: salt://dev/ha/mariadb/templates/galera.template
       - mode: 755
       - template: jinja
       - defaults:
         HOSTNAME: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
         SST_USER: {{ pillar['mariadb'].get('SST_USER') }}
         SST_PASS: {{ pillar['mariadb'].get('SST_PASS') }}
