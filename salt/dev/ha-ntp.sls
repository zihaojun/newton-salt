ntp-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.ntp

ntp-master-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('corosync:NODE_1') }}
     - sls:
       - dev.ha.ntp.cluster.master
     - require:
       - salt: ntp-init

ntp-slave-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('corosync:NODE_2') }}
     - sls:
       - dev.ha.ntp.cluster.slave
     - require:
       - salt: ntp-master-init

