/etc/haproxy/haproxy.cfg:
   file.managed:
      - source: salt://dev/openstack/horizon/templates/haproxy.cfg.template 
      - mode: 644
      - template: jinja
      - defaults: 
        VIP_HOSTNAME: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
        NODE_1: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
        NODE_2: {{ salt['pillar.get']('basic:corosync:NODE_2') }}
        ENABLE_CINDER: {{ salt['pillar.get']('config_cinder_install',False) }}
        ENABLE_HEAT: {{ salt['pillar.get']('config_heat_install',False) }}
        ENABLE_CEILOMETER: {{ salt['pillar.get']('config_ceilometer_install',False) }}
        ENABLE_LOGSTASH: {{ salt['pillar.get']('config_logstash_install',False) }}
        ENABLE_ANIMBUS: {{ salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED',True) }}
   service.running:
      - name: haproxy
      - watch:
        - file: /etc/haproxy/haproxy.cfg

keepalived:
    service.running:
      - watch:
        - file: /etc/haproxy/haproxy.cfg
        - service: /etc/haproxy/haproxy.cfg
