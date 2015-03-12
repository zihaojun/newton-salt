cinder-init:
   pkg.installed:
      - pkgs:
         - openstack-cinder
         - python-cinderclient
         - python-oslo-db
         - targetcli
{% if salt['pillar.get']('basic:cinder:BACKENDS') == 'glusterfs' %}
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
{% endif %}

/etc/cinder/cinder.conf:
    file.managed:
        - source: salt://dev/openstack/cinder/templates/cinder.conf.template
        - mode: 644
        - user: cinder
        - group: cinder
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          BACKENDS: {{ salt['pillar.get']('basic:cinder:BACKENDS') }}
          MYSQL_CINDER_USER: {{ salt['pillar.get']('cinder:MYSQL_CINDER_USER') }}
          MYSQL_CINDER_PASS: {{ salt['pillar.get']('cinder:MYSQL_CINDER_PASS') }}
          MYSQL_CINDER_DBNAME: {{ salt['pillar.get']('cinder:MYSQL_CINDER_DBNAME') }}
          AUTH_ADMIN_CINDER_USER: {{ salt['pillar.get']('cinder:AUTH_ADMIN_CINDER_USER') }}
          AUTH_ADMIN_CINDER_PASS: {{ salt['pillar.get']('cinder:AUTH_ADMIN_CINDER_PASS') }}
        - require:
          - pkg: cinder-init
