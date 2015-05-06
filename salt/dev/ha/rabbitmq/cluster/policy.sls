rabbit_policy:
    rabbitmq_policy.present:
        - name: ha-all
        - pattern: '^(?!amq\.).*'
        - definition: '{"ha-mode": "all"}'
