/etc/corosync/corosync.conf:
   file.managed:
      - source: salt://dev/ha/corosync/templates/corosync.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        HEARTBEAT_NET: {{ salt['pillar.get']('basic:corosync:HEARTBEAT_NET') }}
        NODE_1: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
        NODE_2: {{ salt['pillar.get']('basic:corosync:NODE_2') }}

/etc/corosync/authkey:
   file.managed:
      - source: salt://dev/ha/corosync/files/authkey
      - mode: 400

corosync:
   service.running:
      - enable: True
      - watch:
        - file: /etc/corosync/corosync.conf
        - file: /etc/corosync/authkey

pacemaker:
   service.running:
      - enable: True
      - watch:
        - service: corosync


