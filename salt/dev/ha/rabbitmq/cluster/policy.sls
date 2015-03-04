rabbit_policy:
    rabbitmq_policy.present:
        - name: ha-all
        - pattern: '.*'
        - definition: '{"ha-mode": "all"}'
