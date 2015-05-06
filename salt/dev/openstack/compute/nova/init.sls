nova-compute-init:
   pkg.installed:
      - pkgs:
           - libvirt-daemon
           - libvirt-python
           - libvirt-client
           - dbus
           - ntpdate
           - openstack-nova-compute

/etc/crontab:
  file.managed:
   - source: salt://dev/openstack/compute/ntp/templates/crontab.template
   - user: root
   - group: root
   - mode: 644
   - template: jinja
   - defaults:
     VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }} 

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

/etc/nova/nova.conf:
   file.managed:
        - source: salt://dev/openstack/compute/nova/templates/nova.conf.compute.template
        - mode: 644
        - user: nova
        - group: nova
        - require:
          - pkg: nova-compute-init
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP') }}
          VNC_ENABLED: {{ salt['pillar.get']('nova:VNC_ENABLED') }}
          MYSQL_NOVA_USER: {{ salt['pillar.get']('nova:MYSQL_NOVA_USER') }}
          MYSQL_NOVA_PASS: {{ salt['pillar.get']('nova:MYSQL_NOVA_PASS') }}
          MYSQL_NOVA_DBNAME: {{ salt['pillar.get']('nova:MYSQL_NOVA_DBNAME') }}
          AUTH_ADMIN_NOVA_USER: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_USER') }}
          AUTH_ADMIN_NOVA_PASS: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_PASS') }}
          METADATA_PROXY_SECRET: {{ salt['pillar.get']('nova:METADATA_PROXY_SECRET') }} 
          AUTH_ADMIN_NEUTRON_USER: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_USER') }}
          AUTH_ADMIN_NEUTRON_PASS: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_PASS') }}

{% if salt['pillar.get']('basic:nova:COMPUTE:INSTANCE_BACKENDS','local') == 'glusterfs' %}
/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}:
   mount.mounted:
      - device: localhost:/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}
      - fstype: glusterfs
      - mkmnt: True
      - opts: {{ salt['pillar.get']('basic:glusterfs:MOUNT_OPT') }}

copy-nova-dir:
   cmd.run:
      - name: cp -r /var/lib/nova /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}/
      - unless: test -h /var/lib/nova
      - require:
        - mount: /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}

rmdir-nova-default:
   cmd.run:
      - name: rm -rf /var/lib/nova
      - onlyif: test -d /var/lib/nova
      - require:
        - cmd: copy-nova-dir

/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}/nova:
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
      - target: /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}/nova 
      - require:
        - file: /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}/nova
        - cmd: rmdir-nova-default

mount-volume-reboot:
   file.managed:
      - name: /etc/rc.d/rc.local
      - source: salt://dev/openstack/compute/nova/templates/rc.local.template
      - mode: 755
      - template: jinja
      - defaults: 
        VOLUME_URL: {{ salt['pillar.get']('basic:cinder:VOLUME_URL') }}
        VOLUME_NAME: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }}
{% endif %}
