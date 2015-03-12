mongodb-init:
    salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.ha.mongodb
       - require:
         - salt: hosts-init

mongodb-cluster-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:mongodb:MASTER') }}
     - sls:
       - dev.ha.mongodb.cluster
     - require:
       - salt: mongodb-init

join-mongodb-cluster:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:mongodb:SLAVE') }}
     - sls:
       - dev.ha.mongodb.cluster.add
     - require:
       - salt: mongodb-cluster-init 
