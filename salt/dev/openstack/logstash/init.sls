include:
  - dev.openstack.logstash.common

logstash-init:
   pkg.installed:
      - pkgs:
        - elasticsearch
        - logstash
        - httpd

/etc/elasticsearch/elasticsearch.yml:
   file.managed:
      - source: salt://dev/openstack/logstash/templates/elasticsearch.yml
      - mode: 644
      - template: jinja
      - defaults:
        HOSTNAME: {{ grains['host'] }} 
      - require:
        - pkg: logstash-init

/etc/sysconfig/elasticsearch:
   file.managed:
      - source: salt://dev/openstack/logstash/files/elasticsearch
      - mode: 644
      - require:
        - pkg: logstash-init

extend:
   /etc/logstash/conf.d/collect:
     file.recurse:
         - require:
           - pkg: logstash-init

   /etc/logstash/conf.d/collect/output-rabbitmq.conf:
     file.managed:
         - require:
           - pkg: logstash-init
           - file: /etc/logstash/conf.d/collect

   /opt/logstash/patterns/openstack:
     file.managed:
         - require:
           - pkg: logstash-init

/etc/logstash/conf.d/server/input-rabbitmq.conf:
   file.managed:
      - source: salt://dev/openstack/logstash/templates/server/input-rabbitmq.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
      - require:
        - pkg: logstash-init

/etc/logstash/conf.d/server/output-elastcisearch.conf:
   file.managed:
      - source: salt://dev/openstack/logstash/templates/server/output-elastcisearch.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
      - require:
        - pkg: logstash-init

/tmp/kibana-3.1.2.tar.gz:
   file.managed:
      - source: salt://dev/openstack/logstash/files/kibana-3.1.2.tar.gz 

kibana:
   cmd.run:
      - name: tar xf /tmp/kibana-3.1.2.tar.gz -C /var/www/html/
      - require:
        - file: /tmp/kibana-3.1.2.tar.gz 
      - unless: test -d /var/www/html/kibana*

/var/www/html/kibana:
   file.rename:
      - source: /var/www/html/kibana-3.1.2
      - force: True
      - require:
        - cmd: kibana

/var/www/html/kibana/config.js:
   file.managed:
      - source: salt://dev/openstack/logstash/templates/config.js.template
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP') }}
      - mode: 644
      - require:
        - file: /var/www/html/kibana
