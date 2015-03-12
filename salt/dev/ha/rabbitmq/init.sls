rabbitmq-server:
   pkg.installed:
       - pkgs:
         - rabbitmq-server 
   service.running:
       - enable: True
       - watch:
         - file: /var/lib/rabbitmq/.erlang.cookie


/var/lib/rabbitmq/.erlang.cookie:
   file.managed:
       - source: salt://dev/ha/rabbitmq/files/.erlang.cookie
       - user: rabbitmq
       - group: rabbitmq
       - mode: 400
       - require:
         - pkg: rabbitmq-server
