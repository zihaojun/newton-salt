memcache-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.memcache
     - require:
       - salt: hosts-init
