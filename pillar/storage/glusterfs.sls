include:
   - storage.common

glusterfs:
    VOLUME_NODE: minion-1
    STRIPE: 1
    REPLICA: 2
    VOLUME_NAME: openstack
    TRANSPORT: tcp
    BRICKS: /mnt/gluster
