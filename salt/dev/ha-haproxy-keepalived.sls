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
        - salt: join-rabbitmq-cluster
        - salt: join-galera-cluster
        - salt: join-mongodb-cluster
        - salt: memcache-init
{% if salt['pillar.get']('config_logstash_install',False) %}
        - salt: elasticsearch-service
{% endif %}
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
