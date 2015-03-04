memcache-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.memcache
