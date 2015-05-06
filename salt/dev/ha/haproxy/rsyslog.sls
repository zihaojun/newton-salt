/etc/sysconfig/rsyslog:
   file.managed:
      - source: salt://dev/ha/haproxy/files/rsyslog
      - mode: 644

/etc/rsyslog.d/haproxy.conf:
   file.managed:
      - source: salt://dev/ha/haproxy/files/haproxy.conf
      - mode: 644

/etc/rsyslog.d/keepalived.conf:
   file.managed:
      - source: salt://dev/ha/haproxy/files/keepalived.conf
      - mode: 644

rsyslog:
   service.running:
      - enable: True
      - watch:
        - file: /etc/rsyslog.d/haproxy.conf
        - file: /etc/rsyslog.d/keepalived.conf
        - file: /etc/sysconfig/rsyslog
