include:
  - dev.openstack.nova.common

nova-init:
   pkg.installed:
      - pkgs:
           - openstack-nova-api
           - openstack-nova-cert
           - openstack-nova-conductor
           - openstack-nova-console
           - openstack-nova-novncproxy
           - openstack-nova-scheduler
           - openstack-nova-compute
           - python-novaclient
           - spice-html5
           - openstack-nova-spicehtml5proxy 
           - sysfsutils

extend:
   ch_nova_shell:
     cmd.run:
         - require:
           - pkg: nova-init


salt://dev/openstack/nova/files/nova-db.sh:
    cmd.script:
        - template: jinja
        - require:
          - pkg: nova-init
        - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
{% else %}
          VIP: {{ grains['host'] }}
{% endif %}
          MYSQL_NOVA_USER: {{ salt['pillar.get']('nova:MYSQL_NOVA_USER') }}
          MYSQL_NOVA_PASS: {{ salt['pillar.get']('nova:MYSQL_NOVA_PASS') }}
          MYSQL_NOVA_DBNAME: {{ salt['pillar.get']('nova:MYSQL_NOVA_DBNAME') }}
        - env:
          - BATCH: 'yes'


/etc/libvirt/qemu.conf:
   file.managed:
      - source: salt://dev/openstack/compute/nova/files/qemu.conf
      - mode: 644
      - require:
        - pkg: nova-init

/etc/libvirt/libvirtd.conf:
   file.managed:
       - source: salt://dev/openstack/compute/nova/files/libvirtd.conf
       - mode: 644
       - user: root
       - group: root
       - require:
         - pkg: nova-init

/etc/sysconfig/libvirtd:
   file.managed:
       - source: salt://dev/openstack/compute/nova/files/libvirtd
       - mode: 644
       - user: root
       - group: root
       - require:
         - pkg: nova-init


{% if salt['pillar.get']('config_storage_install',True) and
      salt['pillar.get']('basic:nova:CONTROLLER:COMPUTE_ENABLED',False) and
      salt['pillar.get']('basic:nova:COMPUTE:INSTANCE_BACKENDS','local') == 'glusterfs' %}
/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}_gfs:
   mount.mounted:
      - device: localhost:/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}
      - fstype: glusterfs
      - mkmnt: True
      - persist: False
      - opts: {{ salt['pillar.get']('basic:glusterfs:MOUNT_OPT') }}

copy-nova-dir:
   cmd.run:
      - name: cp -r /var/lib/nova /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}_gfs/
      - unless: test -h /var/lib/nova
      - require:
        - mount: /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}_gfs

rmdir-nova-default:
   cmd.run:
      - name: rm -rf /var/lib/nova
      - onlyif: test -d /var/lib/nova
      - require:
        - cmd: copy-nova-dir

/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}_gfs/nova:
   file.directory:
      - user: nova
      - group: nova
      - dir_mode: 755
      - file_mode: 644
      - recurse:
        - user
        - group
        - mode
      - require:
        - cmd: copy-nova-dir

/var/lib/nova:
   file.symlink:
      - target: /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}_gfs/nova
      - require:
        - file: /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}_gfs/nova
        - cmd: rmdir-nova-default

/var/lib/nova/.ssh:
   file.recurse:
      - source: salt://dev/openstack/compute/nova/files/ssh_nopass
      - dir_mode: 700
      - file_mode: 600
      - user: nova
      - group: nova
      - require:
        - file: /var/lib/nova

/etc/rc.d/rc.local:
   file.append:
     - text:
       - mount -t glusterfs localhost:/{{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }}
         /{{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }}_gfs
{% endif %}
