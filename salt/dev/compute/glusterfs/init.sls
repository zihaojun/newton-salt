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
