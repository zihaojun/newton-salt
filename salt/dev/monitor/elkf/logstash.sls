logstash-init:
  pkg.installed:
    - pkgs:
      - logstash

/etc/logstash/conf.d/logstash.conf:
  file.managed:
    - source: salt://dev/monitor/elkf/files/logstash.conf
    - template: jinja
    - default:
      CONTROLLER_IP: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
    - require:
      - pkg: logstash-init

logstash-service:
  service.running:
    - name: logstash
    - enable: True
    - require:
      - file: /etc/logstash/conf.d/logstash.conf
