mongodb-init:
    salt.state:
       - tgt: {{ salt['pillar.get']('corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.ha.mongodb

mongodb-cluster-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('mongodb:MASTER') }}
     - sls:
       - dev.ha.mongodb.cluster
     - require:
       - salt: mongodb-init

join-mongodb-cluster:
  salt.state:
     - tgt: {{ salt['pillar.get']('mongodb:SLAVE') }}
     - sls:
       - dev.ha.mongodb.cluster.add
     - require:
       - salt: mongodb-cluster-init 
