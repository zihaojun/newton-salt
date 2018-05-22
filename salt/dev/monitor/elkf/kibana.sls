kibana-init:
  pkg.installed:
    - pkgs:
      - kibana

/opt/kibana/config/kibana.yml:
  file.managed:
    - source: salt://dev/monitor/elkf/files/kibana.yml
    - template: jinja
    - default:
      CONTROLLER_IP: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
    - require:
      - pkg: kibana-init

kibana-service:
  service.running:
    - name: kibana
    - enable: True
    - require:
      - file: /opt/kibana/config/kibana.yml
