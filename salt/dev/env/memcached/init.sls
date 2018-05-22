memc:
  pkg.installed:
    - pkgs:
      - memcached
      - python-memcached

memc-service:
  file.managed:
    - name: /etc/sysconfig/memcached
    - source: salt://dev/env/memcached/templates/memcached.template
    - template: jinja
    - default:
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
    - require:
      - pkg: memc
  service.running:
    - name: memcached
    - enable: True
    - require:
      - file: memc-service

memc-enable:
  cmd.run:
    - name: systemctl enable memcached.service
    - unless: systemctl list-dependencies | grep memcached
    - require:
      - pkg: memc
