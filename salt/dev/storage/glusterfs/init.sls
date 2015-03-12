glusterfs-init:
   pkg.installed:
      - pkgs:
        - glusterfs
        - glusterfs-libs
        - glusterfs-fuse
        - glusterfs-cli
        - glusterfs-server
        - glusterfs-api

/etc/crontab:
  file.managed:
   - source: salt://dev/openstack/compute/ntp/templates/crontab.template
   - user: root
   - group: root
   - mode: 644
   - template: jinja
   - defaults:
     VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}

glusterd:
   service.running:
      - enable: True
      - require:
        - pkg: glusterfs-init

crond:
   service.running:
      - enable: True
      - watch:
        - file: /etc/crontab
