compute-glusterfs-init:
  salt.state:
    - tgt: '*'
    - sls:
      - dev.compute.glusterfs
