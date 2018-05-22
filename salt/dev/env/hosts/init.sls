/etc/hosts:
  file.managed:
    - source: salt://dev/env/hosts/templates/hosts.template
    - template: jinja
    - default:
      NODES: {{ salt['pillar.get']('nova:HOSTS','') }}
