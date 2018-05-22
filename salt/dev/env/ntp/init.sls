ntp:
  pkg.installed:
    - pkgs:
      - chrony

/etc/chrony.conf:
  file.managed:
    - source: salt://dev/env/ntp/templates/chrony.template
    - template: jinja
    - default:
{% if salt['pillar.get']('compute:ENABLED') %}
      NTP_SERVER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      NET: {{ salt['pillar.get']('neutron:NET') }}
{% else %}
      NTP_SERVER: 211.152.61.4
      NET: {{ salt['pillar.get']('neutron:NET') }}
{% endif %}
    - require:
      - pkg: ntp

ntp-service:
  cmd.run:
    - name: systemctl enable chronyd.service
    - unless: systemctl list-dependencies | grep chronyd
    - require:
      - file: /etc/chrony.conf
  service.running:
    - name: chronyd
    - enable: True
    - require:
      - cmd: ntp-service
    - watch:
      - file: /etc/chrony.conf

time-sync:
  cmd.run:
    - name: chronyc sources
    - require:
      - service: ntp-service
