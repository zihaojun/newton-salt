mariadb-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.mariadb
     - require:
       - salt: hosts-init

create-sst-user:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.mariadb.create-auth-user
     - require:
       - salt: mariadb-init

galera-cluster-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:mariadb:MASTER') }}
     - sls:
       - dev.ha.mariadb.cluster
     - require:
       - salt: create-sst-user

join-galera-cluster:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:mariadb:SLAVE') }}
     - sls:
       - dev.ha.mariadb.cluster.add
     - require:
       - salt: galera-cluster-init
