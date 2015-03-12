corosync-pacemaker-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.corosync
     - require:
       - salt: hosts-init

ha-cluster-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.corosync.cluster
     - require:
       - salt: corosync-pacemaker-init

cluster-add-resource:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
     - sls: 
       - dev.ha.corosync.cluster.add
     - require:
       - salt: ha-cluster-init

