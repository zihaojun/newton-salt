include:
  - dev.openstack.cinder.db
  - dev.openstack.cinder.create-auth-user

cinder:
  pkg.installed:
    - pkgs:
      - openstack-cinder
      - targetcli
      - python-keystone

/etc/cinder/shares.conf:
  file.managed:
    - source: salt://dev/openstack/cinder/templates/shares.conf
    - user: root
    - group: cinder
    - require:
      - pkg: cinder

/etc/cinder/cinder.conf:
  file.managed:
    - source: salt://dev/openstack/cinder/templates/cinder.conf.template
    - template: jinja
    - default:
      CINDER_DBPASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      CONTROLLER_IP: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
      CINDER_USER_PASS: {{ salt['pillar.get']('public_password') }}
      STORAGETYPE: {{ salt['pillar.get']('storage:TYPE') }}
    - require:
      - pkg: cinder

cinder-back:
  cmd.run:
    - name: sed -i '$a [glusterfs]\nvolume_driver=cinder.volume.drivers.glusterfs.GlusterfsDriver\nvolume_backend_name=GlusterFS\nglusterfs_shares_config=/etc/cinder/shares.conf\nglusterfs_mount_point_base=/var/lib/cinder/tmp' /etc/cinder/cinder.conf
    - require:
      - file: /etc/cinder/cinder.conf

cinder-service:
  cmd.script:
    - source: salt://dev/openstack/cinder/templates/cinder-service.sh
    - require:
      - cmd: cinder-back
      - mysql_database: cinder-database
