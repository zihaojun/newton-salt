slave-ntp:
   file.managed:
      - name: /etc/ntp.conf
      - source: salt://dev/ha/ntp/templates/ntp.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        MASTER_ENABLED: False
        MASTER: {{ salt['pillar.get']('corosync:NODE_1') }} 
   service.running:
      - name: ntpd
      - enable: True
      - watch:
        - file: slave-ntp 
