include:
   - dev.storage.glusterfs.pkg

/etc/crontab:
  file.managed:
   - source: salt://dev/openstack/compute/ntp/templates/crontab.template
   - user: root
   - group: root
   - mode: 644
   - template: jinja
   - defaults:
     VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}

crond:
   service.running:
      - enable: True
      - watch:
        - file: /etc/crontab
