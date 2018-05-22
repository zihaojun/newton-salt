{% set devnames = salt['pillar.get']('storage:HARDNAME') %}
{% set vgname = salt['pillar.get']('storage:VGNAME') %}
{% set vgdevs = salt['pillar.get']('storage:VGDEVS') %}
{% set controller_ip = salt['pillar.get']('nova:CONTROLLER_IP') %}

glusterfs:
  pkg.installed:
    - pkgs:
      - glusterfs-api
      - glusterfs-cli
      - glusterfs-client-xlators
      - glusterfs-libs
      - glusterfs-rdma
      - glusterfs
      - glusterfs-fuse
      - glusterfs-server

glusterfs-service:
  cmd.run:
    - name: systemctl enable glusterd && systemctl start glusterd
    - require:
      - pkg: glusterfs

/gfs:
  file.directory:
    - user: root
    - group: root
    - require:
      - cmd: glusterfs-service

/glance_gfs:
  file.directory:
    - require:
      - file: /gfs

{% for i in range(0,devnames|length) %}
dev/{{ devnames[i] }}:
  cmd.run:
    - name: pvcreate -y /dev/{{ devnames[i] }}
{% endfor %}

createvg:
  cmd.run:
    - name: vgcreate {{ vgname }} {{ vgdevs }}
    - require:
      - cmd: dev/{{ devnames[0] }}

createlv:
  cmd.run:
    - name: lvcreate -l +100%FREE -n {{ vgname }} {{ vgname }} && mkfs.xfs -f /dev/{{ vgname }}/{{ vgname }}
    - require:
      - cmd: createvg

create_brick:
  cmd.run:
    - name: echo "/dev/{{ vgname }}/{{ vgname }}            /gfs                    xfs     defaults        0 0" >> /etc/fstab && mount -a
    - require:
      - cmd: createlv

create_glance_volume:
  glusterfs.peered:
    - name: {{ controller_ip }}
    - require:
      - cmd: create_brick
create_glance_volume1:
  glusterfs.created:
    - name: glance
    - bricks:
      - {{ controller_ip }}:/{{ vgname }}/{{ vgname }}
    - start: True
    - require:
      - glusterfs: create_glance_volume
create_glance_volume2:
  cmd.run:
    - name: gluster volume set glance server.allow-insecure on && echo "localhost:glance        /glance_gfs             glusterfs       defaults        0 0" >> /etc/fstab && mount -a
    - require:
      - glusterfs: create_glance_volume1
