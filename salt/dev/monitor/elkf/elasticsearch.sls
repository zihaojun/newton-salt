es-init:
  pkg.installed:
    - pkgs:
      - elasticsearch

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://dev/monitor/elkf/files/elasticsearch.yml
    - template: jinja
    - default:
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      CONTROLLER_IP: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
    - require:
      - pkg: es-init

es-service:
  service.running:
    - name: elasticsearch
    - enable: True
    - require:
      - file: /etc/elasticsearch/elasticsearch.yml
