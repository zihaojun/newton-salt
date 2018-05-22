/etc/systemd/system/gluster_exporter.service:
  file.managed:
    - source: salt://dev/monitor/glustermon/files/gluster_exporter.service

gluster_exporter:
  file.managed:
    - name: /home/gluster_exporter
    - source: salt://dev/monitor/glustermon/files/gluster_exporter
    - mode: 755
    - require:
      - file: /etc/systemd/system/gluster_exporter.service
  service.running:
    - name: gluster_exporter
    - enable: True
    - require:
      - file: gluster_exporter

/etc/systemd/system/prometheus.service:
  file.managed:
    - source: salt://dev/monitor/glustermon/files/prometheus.service

/var/lib/prometheus:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - file: /etc/systemd/system/prometheus.service

prometheus-init:
  cmd.run:
    - name: cd /srv/openstack-deploy/salt/dev/monitor/glustermon/files && tar -zxvf prometheus.tar.gz -C /home/
    - unless: test -d /home/prometheus
    - require:
      - file: /var/lib/prometheus
  service.running:
    - name: prometheus
    - enable: True
    - require:
      - cmd: prometheus-init
