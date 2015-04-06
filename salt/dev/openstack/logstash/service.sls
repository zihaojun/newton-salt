elasticsearch:
    service.running:
      - enable: True

logstash-collect:
   service.running:
      - enable: True
      - watch:
        - service: elasticsearch

logstash-server:
   service.running:
      - enable: True
      - watch:
        - service: elasticsearch
