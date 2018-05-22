mongodb:
  pkg.installed:
    - pkgs:
      - mongodb-server
      - mongodb

/etc/mongod.conf:
  file.managed:
    - source: salt://dev/openstack/ceilometer/templates/mongod.conf.template
    - template: jinja
    - default:
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
    - require:
      - pkg: mongodb

service-init:
  cmd.run:
    - name: systemctl enable mongod.service
    - unless: systemctl list-unit-files | grep enabled | grep mongod
    - require:
      - file: /etc/mongod.conf
  service.running:
    - name: mongod
    - enable: True
    - require:
      - cmd: service-init
    - watch:
      - file: /etc/mongod.conf
