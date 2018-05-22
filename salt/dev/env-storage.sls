glusterfs-setup:
  salt.state:
    - tgt: {{ salt['pillar.get']('nova:CONTROLLER') }}
    - sls:
      - dev.env.storage.glusterfs
