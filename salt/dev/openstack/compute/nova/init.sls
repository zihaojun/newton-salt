include:
  - dev.openstack.nova.common

nova-compute-init:
   pkg.installed:
      - pkgs:
           - libvirt-daemon
           - libvirt-python
           - libvirt-client
           - dbus
           - ntpdate
           - openstack-nova-compute
           - sysfsutils

extend:
   ch_nova_shell:
     cmd.run:
         - require:
           - pkg: nova-compute-init

/etc/crontab:
  file.managed:
   - source: salt://dev/openstack/compute/ntp/templates/crontab.template
   - user: root
   - group: root
   - mode: 644
   - template: jinja
   - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
     VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }} 
{% else %}
     VIP: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
{% endif %}

/etc/libvirt/qemu.conf:
   file.managed:
      - source: salt://dev/openstack/compute/nova/files/qemu.conf
      - mode: 644
      - require:
        - pkg: nova-compute-init

/etc/libvirt/libvirtd.conf:
   file.managed:
       - source: salt://dev/openstack/compute/nova/files/libvirtd.conf
       - mode: 644
       - user: root
       - group: root
       - require:
         - pkg: nova-compute-init

/etc/sysconfig/libvirtd:
   file.managed:
       - source: salt://dev/openstack/compute/nova/files/libvirtd
       - mode: 644
       - user: root
       - group: root
       - require:
         - pkg: nova-compute-init


{% if salt['pillar.get']('config_storage_install',True) and
      salt['pillar.get']('basic:nova:COMPUTE:INSTANCE_BACKENDS','local') == 'glusterfs' %}
/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}_gfs:
   mount.mounted:
      - device: localhost:/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}
      - fstype: glusterfs
      - mkmnt: True
      - persist: False
      - opts: {{ salt['pillar.get']('basic:glusterfs:MOUNT_OPT') }}
      - persist: False

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
