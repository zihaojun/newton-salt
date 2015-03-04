corosync-pacemaker-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.corosync

ha-cluster-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.corosync.cluster
     - require:
       - salt: corosync-pacemaker-init

add-resource:
  salt.state:
     - tgt: {{ salt['pillar.get']('corosync:NODE_1') }}
     - sls: 
       - dev.ha.corosync.cluster.add
     - require:
       - salt: ha-cluster-init

