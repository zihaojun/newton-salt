rabbitmq-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.rabbitmq
     - require:
       - salt: hosts-init


join-rabbitmq-cluster:
  salt.state:
     - tgt:  {{ salt['pillar.get']('basic:rabbitmq:RAM_NODE') }}
     - sls:  dev.ha.rabbitmq.cluster
     - require:
       - salt: rabbitmq-init

set-policy:
  salt.state:
     - tgt:  {{ salt['pillar.get']('basic:rabbitmq:DISC_NODE') }}
     - sls:  dev.ha.rabbitmq.cluster.policy
     - require:
       - salt: join-rabbitmq-cluster
