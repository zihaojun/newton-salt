master-mongodb-conf:
    file.managed:
       - name: /etc/mongodb.conf
       - source: salt://dev/ha/mongodb/templates/mongodb.conf.template
       - mode: 644
       - template: jinja
       - defaults:
         HOSTNAME: {{ grains['host'] }}
         MASTER_ENABLED: True
    service.running:
       - name: mongod 
       - enable: True
       - watch:
         - file: master-mongodb-conf 
