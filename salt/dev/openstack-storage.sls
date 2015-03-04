{% if salt['pillar.get']('cinder:BACKENDS') == 'glusterfs' %}
glusterfs-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('storage-common:NODES') }}
       - tgt_type: list
       - sls:
         - dev.storage.glusterfs

glusterfs-peer:
   salt.state:
       - tgt: {{ salt['pillar.get']('glusterfs:VOLUME_NODE') }}
       - sls:
         - dev.storage.glusterfs.cluster
       - require:
         - salt: glusterfs-init

glusterfs-volume:
   salt.state:
       - tgt: {{ salt['pillar.get']('glusterfs:VOLUME_NODE') }}
       - sls:
         - dev.storage.glusterfs.volume
       - require:
         - salt: glusterfs-peer

{% elif salt['pillar.get']('cinder:BACKENDS') == 'ceph' %}
ceph-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('common:NODES') }}
       - tgt_type: list
       - sls:
         - dev.storage.ceph
{% endif %}


