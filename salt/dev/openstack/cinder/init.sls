cinder-init:
   pkg.installed:
      - pkgs:
         - openstack-cinder
         - python-cinderclient
         - python-oslo-db
         - targetcli
{% if salt['pillar.get']('config_storage_install',True) and 
      salt['pillar.get']('basic:cinder:BACKENDS') == 'glusterfs' %}
         - glusterfs
         - glusterfs-libs
         - glusterfs-fuse
         - glusterfs-api

/etc/cinder/glusterfs_shares:
    file.managed:
        - source: salt://dev/openstack/cinder/templates/glusterfs_shares.template
        - mode: 644
        - user: cinder
        - group: cinder
        - template: jinja
        - defaults:
          VOLUME_URL: {{ salt['pillar.get']('basic:cinder:VOLUME_URL') }}
        - require:
          - pkg: cinder-init

{% elif salt['pillar.get']('basic:cinder:BACKENDS') == 'lvm' %}
salt://dev/openstack/cinder/files/cinder-volumes.sh:
    cmd.script:
        - require:
          - pkg: cinder-init
{% endif %}


salt://dev/openstack/cinder/files/cinder-db.sh:
    cmd.script:
        - template: jinja
        - require:
          - pkg: cinder-init
        - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
{% else %}
          VIP: {{ grains['host'] }}
{% endif %}
          MYSQL_CINDER_USER: {{ salt['pillar.get']('cinder:MYSQL_CINDER_USER') }}
          MYSQL_CINDER_PASS: {{ salt['pillar.get']('cinder:MYSQL_CINDER_PASS') }}
          MYSQL_CINDER_DBNAME: {{ salt['pillar.get']('cinder:MYSQL_CINDER_DBNAME') }}
        - env:
          - BATCH: 'yes'
