master-my-cnf:
    file.managed:
       - name: /etc/my.cnf
       - source: salt://dev/ha/mariadb/templates/my.cnf.template
       - mode: 644
       - template: jinja
       - defaults:
         ID: 1
         HOSTNAME: {{ grains['host'] }}
         MASTER_ENABLED: True
         SST_USER: {{ pillar['mariadb'].get('SST_USER') }}
         SST_PASS: {{ pillar['mariadb'].get('SST_PASS') }}   
    service.running:
       - name: mysql 
       - enable: True
       - watch:
         - file: master-my-cnf
