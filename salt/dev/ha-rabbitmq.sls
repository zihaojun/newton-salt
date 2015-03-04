rabbitmq-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.rabbitmq

join-cluster:
  salt.state:
     - tgt:  {{ salt['pillar.get']('rabbitmq:RAM_NODE') }}
     - sls:  dev.ha.rabbitmq.cluster
     - require:
       - salt: rabbitmq-init

set-policy:
  salt.state:
     - tgt:  {{ salt['pillar.get']('rabbitmq:DISC_NODE') }}
     - sls:  dev.ha.rabbitmq.cluster.policy
     - require:
       - salt: join-cluster
