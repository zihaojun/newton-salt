filebeat-init:
  pkg.installed:
    - pkgs:
      - filebeat

/etc/filebeat/filebeat.yml:
  file.managed:
{% if salt['pillar.get']('compute:ENABLED') == True %}
    - source: salt://dev/monitor/elkf/files/filebeat-compute.yml
{% else %}
    - source: salt://dev/monitor/elkf/files/filebeat.yml
{% endif %}
    - template: jinja
    - default:
      CONTROLLER_IP: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
    - require:
      - pkg: filebeat-init

filebeat-service:
  service.running:
    - name: filebeat
    - enable: True
    - require:
      - file: /etc/filebeat/filebeat.yml
  
    
