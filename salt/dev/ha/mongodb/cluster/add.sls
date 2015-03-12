slave-mongodb-conf:
    file.managed:
       - name: /etc/mongodb.conf 
       - source: salt://dev/ha/mongodb/templates/mongodb.conf.template
       - mode: 644
       - template: jinja
       - defaults:
         HOSTNAME: {{ grains['host'] }}
         MASTER: {{ salt['pillar.get']('basic:mongodb:MASTER') }}
         MASTER_ENABLED: False
    service.running:
       - name: mongod
       - enable: True
       - watch:
         - file: slave-mongodb-conf
