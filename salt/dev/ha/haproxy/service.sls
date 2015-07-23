haproxy:
   service:
      - running
      - watch:
        - file: /etc/haproxy/haproxy.cfg

/etc/haproxy/haproxy.cfg:
   file.managed:
      - source: salt://dev/ha/haproxy/templates/haproxy.cfg.template
      - mode: 644
      - template: jinja
      - defaults:
        VIP_HOSTNAME: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
        NODE_1: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
        NODE_2: {{ salt['pillar.get']('basic:corosync:NODE_2') }}
        ENABLE_LOGSTASH: {{ salt['pillar.get']('config_logstash_install',False) }}
        ENABLE_ANIMBUS: {{ salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED',True) }}
