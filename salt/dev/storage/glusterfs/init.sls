glusterfs-init:
   pkg.installed:
      - pkgs:
        - glusterfs
        - glusterfs-libs
        - glusterfs-fuse
        - glusterfs-cli
        - glusterfs-server
        - glusterfs-api

glusterd:
   service.running:
      - enable: True
      - require:
        - pkg: glusterfs-init
