logstash-init:
   pkg.installed:
      - pkgs:
        - elasticsearch
        - logstash
        - logstash-contrib
        - httpd

/etc/elasticsearch/elasticsearch.yml:
   file.managed:
      - source: salt://dev/openstack/logstash/files/elasticsearch.yml
      - mode: 644
      - require:
        - pkg: logstash-init

/etc/logstash/conf.d/broker.conf:
   file.managed:
      - source: salt://dev/openstack/logstash/templates/broker.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
        NODE_1: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
      - require:
        - pkg: logstash-init

/etc/logstash/conf.d/shipper.conf:
   file.managed:
      - source: salt://dev/openstack/logstash/templates/shipper.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
      - require:
        - pkg: logstash-init

/opt/logstash/patterns/openstack:
   file.managed:
      - source: salt://dev/openstack/logstash/files/openstack.pattern
      - mode: 644
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
      - unless: test -f /var/www/html/kibana*

/var/www/html/kibana:
   file.rename:
      - source: /var/www/html/kibana-3.1.2
      - force: True
      - require:
        - cmd: kibana

{% set node_1 = salt['pillar.get']('basic:corosync:NODE_1') %}
/var/www/html/kibana/config.js:
   file.managed:
      - source: salt://dev/openstack/logstash/templates/config.js.template
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('basic:nova:CONTROLLER:HOSTS')[node_1] }}
      - mode: 644
      - require:
        - file: /var/www/html/kibana
