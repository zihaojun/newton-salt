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

{% if salt['pillar.get']('config_ha_install',False) %}
/etc/init.d/galera:
    file.managed:
       - source: salt://dev/ha/mariadb/templates/galera.template
       - mode: 755
       - template: jinja
       - defaults:
         HOSTNAME: {{ salt['pillar.get']('basic:corosync:NODE_2') }}
         SST_USER: {{ pillar['mariadb'].get('SST_USER') }}
         SST_PASS: {{ pillar['mariadb'].get('SST_PASS') }}
{% endif %}
