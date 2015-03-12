elasticsearch:
    service.running:
      - enable: True

logstash:
   service.running:
      - enable: True
      - watch:
        - service: elasticsearch

