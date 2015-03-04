master-ntp:
   file.managed:
      - name: /etc/ntp.conf
      - source: salt://dev/ha/ntp/templates/ntp.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        MASTER_ENABLED: True
   service.running:
      - name: ntpd
      - enable: True
      - watch:
        - file: master-ntp 

