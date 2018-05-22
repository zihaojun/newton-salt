rabbitmq:
  pkg.installed:
    - pkgs:
      - rabbitmq-server
  service.running:
    - name: rabbitmq-server
    - enable: True
    - require:
      - pkg: rabbitmq

rabbituser: 
  cmd.script:
    - source: salt://dev/env/rabbitmq/create_user.sh
    - require:
      - service: rabbitmq
