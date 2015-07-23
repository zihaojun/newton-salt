elasticsearch-init:
   pkg.installed:
      - pkgs:
        - java-1.7.0-openjdk
        - elasticsearch

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
