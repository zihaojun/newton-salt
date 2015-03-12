rabbit@{{ salt['pillar.get']('basic:rabbitmq:DISC_NODE') }}:
   rabbitmq_cluster.join:
      - user: rabbit
      - host: {{ salt['pillar.get']('basic:rabbitmq:DISC_NODE') }}
