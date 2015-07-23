glance-init:
   pkg.installed:
      - pkgs:
        - openstack-glance
        - python-glanceclient
{% if salt['pillar.get']('basic:glance:IMAGE_BACKENDS','local') == 'glusterfs' %}
        - glusterfs
        - glusterfs-libs
        - glusterfs-fuse
        - glusterfs-api
{% endif %}

{% for srv in ['api','registry'] %}
/var/log/glance/{{srv}}.log:
     file.managed:
        - user: glance
        - group: glance
        - mode: 644
        - require:
          - pkg: glance-init
{% endfor %}

salt://dev/openstack/glance/files/glance-db.sh:
    cmd.script:
        - template: jinja
        - require:
          - pkg: glance-init
        - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
{% else %}
          VIP: {{ grains['host'] }}
{% endif %}
          MYSQL_GLANCE_USER: {{ salt['pillar.get']('glance:MYSQL_GLANCE_USER') }}
          MYSQL_GLANCE_PASS: {{ salt['pillar.get']('glance:MYSQL_GLANCE_PASS') }}
          MYSQL_GLANCE_DBNAME: {{ salt['pillar.get']('glance:MYSQL_GLANCE_DBNAME') }}
        - env:
          - BATCH: 'yes'


{% if salt['pillar.get']('config_storage_install',True) and 
     salt['pillar.get']('basic:glance:IMAGE_BACKENDS','local') == 'glusterfs' %}
/{{salt['pillar.get']('basic:glance:VOLUME_NAME')}}_gfs:
   mount.mounted:
      - device: localhost:/{{salt['pillar.get']('basic:glance:VOLUME_NAME')}}
      - fstype: glusterfs
      - mkmnt: True
      - persist: False
      - opts: {{ salt['pillar.get']('basic:glusterfs:MOUNT_OPT') }}
      - persist: False

copy-glance-dir:
   cmd.run:
      - name: cp -r /var/lib/glance /{{salt['pillar.get']('basic:glance:VOLUME_NAME')}}_gfs/
      - unless: test -h /var/lib/glance
      - require:
        - mount: /{{salt['pillar.get']('basic:glance:VOLUME_NAME')}}_gfs

rmdir-glance-default:
   cmd.run:
      - name: rm -rf /var/lib/glance
      - onlyif: test -d /var/lib/glance
      - require:
        - cmd: copy-glance-dir

/{{salt['pillar.get']('basic:glance:VOLUME_NAME')}}_gfs/glance:
   file.directory:
      - user: glance
      - group: glance
      - dir_mode: 755
      - file_mode: 644
      - recurse:
        - user
        - group
        - mode
      - require:
        - cmd: copy-glance-dir

/var/lib/glance:
   file.symlink:
      - target: /{{salt['pillar.get']('basic:glance:VOLUME_NAME')}}_gfs/glance 
      - require:
        - file: /{{salt['pillar.get']('basic:glance:VOLUME_NAME')}}_gfs/glance
        - cmd: rmdir-glance-default

/etc/rc.d/rc.local:
   file.append:
     - text:
       - mount -t glusterfs localhost:/{{ salt['pillar.get']('basic:glance:VOLUME_NAME') }} 
         /{{ salt['pillar.get']('basic:glance:VOLUME_NAME') }}_gfs
{% endif %}
