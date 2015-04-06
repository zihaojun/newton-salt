/etc/logstash/conf.d/collect:
   file.recurse:
      - source: salt://dev/openstack/logstash/files/collect
      - dir_mode: 755
      - file_mode: 644

/etc/logstash/conf.d/collect/output-rabbitmq.conf:
   file.managed:
      - source: salt://dev/openstack/logstash/templates/collect/output-rabbitmq.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}

/opt/logstash/patterns/openstack:
   file.managed:
      - source: salt://dev/openstack/logstash/files/openstack.pattern
      - mode: 644
