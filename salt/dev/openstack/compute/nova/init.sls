nova-compute-init:
   pkg.installed:
      - pkgs:
           - libvirt-daemon
           - libvirt-python
           - libvirt-client
           - dbus
           - openstack-nova-compute
           
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
        - source: salt://dev/openstack/compute/nova/templates/nova.conf.template
        - mode: 644
        - user: nova
        - group: nova
        - require:
          - pkg: nova-compute-init
        - template: jinja
        - defaults:
           
