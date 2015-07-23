rabbitmq-server:
   pkg.installed:
       - pkgs:
         - rabbitmq-server 
   service.running:
       - enable: True
       - watch:
         - file: /var/lib/rabbitmq/.erlang.cookie
         - file: /etc/rabbitmq/rabbitmq-env.conf
         - file: /etc/rabbitmq/rabbitmq.config


{{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}:
    rabbitmq_user.present:
        - password: "{{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}" 
        - force: True
        - perms:
          - '/':
            - '.*'
            - '.*'
            - '.*'
        - runas: rabbitmq
        - require:
          - service: rabbitmq-server

/var/lib/rabbitmq/.erlang.cookie:
   file.managed:
       - source: salt://dev/ha/rabbitmq/files/.erlang.cookie
       - user: rabbitmq
       - group: rabbitmq
       - mode: 400
       - require:
         - pkg: rabbitmq-server

/etc/rabbitmq/rabbitmq-env.conf:
   file.managed:
       - source: salt://dev/ha/rabbitmq/files/rabbitmq-env.conf
       - user: rabbitmq
       - group: rabbitmq
       - mode: 644
       - require:
         - pkg: rabbitmq-server

/etc/rabbitmq/rabbitmq.config:
   file.managed:
       - source: salt://dev/ha/rabbitmq/templates/rabbitmq.config.template
       - template: jinja
       - defaults:
         HOSTNAME: {{ grains['host'] }} 
       - user: rabbitmq
       - group: rabbitmq
       - mode: 644
       - require:
         - pkg: rabbitmq-server
