elasticsearch-init:
   pkg.installed:
      - pkgs:
        - java-1.7.0-openjdk
        - elasticsearch

/etc/elasticsearch/elasticsearch.yml:
   file.managed:
      - source: salt://dev/ha/elasticsearch/templates/elasticsearch.yml.template
      - mode: 644
      - template: jinja
      - defaults:
        HOSTNAME: {{ grains['host'] }}
      - require:
        - pkg: elasticsearch-init

/etc/sysconfig/elasticsearch:
   file.managed:
      - source: salt://dev/ha/elasticsearch/files/elasticsearch
      - mode: 644
      - require:
        - pkg: elasticsearch-init


crontab-delete-data:
  file.managed:
   - name: /etc/crontab
   - source: salt://dev/ha/elasticsearch/templates/crontab.template
   - user: root
   - group: root
   - mode: 644
   - template: jinja
   - defaults:
     VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}

crond-delete-service:
   service.running:
      - name: crond
      - enable: True
      - watch:
        - file: crontab-delete-data
