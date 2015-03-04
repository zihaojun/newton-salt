mariadb-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.mariadb

galera-cluster-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('mariadb:MASTER') }}
     - sls:
       - dev.ha.mariadb.cluster
     - require:
       - salt: mariadb-init

join-galera-cluster:
  salt.state:
     - tgt: {{ salt['pillar.get']('mariadb:SLAVE') }}
     - sls:
       - dev.ha.mariadb.cluster.add
     - require:
       - salt: galera-cluster-init
