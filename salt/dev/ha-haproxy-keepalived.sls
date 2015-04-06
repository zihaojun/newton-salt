haproxy-keepalived-init:
   salt.state:
      - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
      - tgt_type: list
      - sls:
        - dev.ha.haproxy

add-haproxy-rsyslog:
   salt.state:
      - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
      - tgt_type: list
      - sls:
        - dev.ha.haproxy.rsyslog 

{% if salt['pillar.get']('haproxy:ENABLE_KEEPALIVED') %}
haproxy-keepalived:
   salt.state:
      - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
      - tgt_type: list
      - sls:
        - dev.ha.haproxy.keepalived
      - require:
        - salt: haproxy-keepalived-init

haproxy-service:
   salt.state:
      - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
      - tgt_type: list
      - sls:
        - dev.ha.haproxy.service
      - require:
        - salt: haproxy-keepalived

{% else %}
crm-haproxy:
   salt.state:
      - tgt: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
      - sls:
        - dev.ha.haproxy.cluster.add
      - require:
        - salt: haproxy-keepalived-init
        - salt: cluster-add-resource
{% endif %}
