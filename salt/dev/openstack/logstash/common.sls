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
{% if salt['pillar.get']('config_ha_install',False) %}
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
{% else %}
        VIP: {{ grains['host'] }} 
{% endif %}
        RABBIT_USER: {{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}
        RABBIT_PASS: {{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}

/opt/logstash/patterns/openstack:
   file.managed:
      - source: salt://dev/openstack/logstash/files/openstack.pattern
      - mode: 644
