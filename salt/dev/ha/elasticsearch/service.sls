elasticsearch:
    service.running:
      - enable: True
      - watch:
        - file: /etc/elasticsearch/elasticsearch.yml
        - file: /etc/sysconfig/elasticsearch

/etc/elasticsearch/elasticsearch.yml:
   file.managed:
      - source: salt://dev/ha/elasticsearch/templates/elasticsearch.yml.template
      - mode: 644
      - template: jinja
      - defaults:
        HOSTNAME: {{ grains['host'] }}

/etc/sysconfig/elasticsearch:
   file.managed:
      - source: salt://dev/ha/elasticsearch/files/elasticsearch
      - mode: 644
