
rabbit@{{ salt['pillar.get']('rabbitmq:DISC_NODE') }}:
   rabbitmq_cluster.join:
      - user: rabbit
      - host: {{ salt['pillar.get']('rabbitmq:DISC_NODE') }}
      - ram_node: True
