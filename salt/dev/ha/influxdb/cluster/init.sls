master-influxdb-conf:
    file.managed:
       - name: /etc/opt/influxdb/influxdb.conf
       - source: salt://dev/ha/influxdb/templates/influxdb.conf.template
       - mode: 644
       - template: jinja
       - defaults:
         HOSTNAME: {{ grains['host'] }}
    service.running:
       - name: influxdb 
       - enable: True
       - watch:
         - file: master-influxdb-conf
