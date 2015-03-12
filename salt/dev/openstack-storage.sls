{% if salt['pillar.get']('basic:cinder:BACKENDS') == 'glusterfs' %}
glusterfs-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:storage-common:NODES') }}
       - tgt_type: list
       - sls:
         - dev.storage.glusterfs
       - require:
         - salt: hosts-init

glusterfs-peer:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NODE') }}
       - sls:
         - dev.storage.glusterfs.cluster
       - require:
         - salt: glusterfs-init

{% if salt['pillar.get']('basic:storage-common:ADD_NODE_ENABLED',False) %}
glusterfs-volume-add-bricks:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NODE') }} 
       - sls:
         - dev.storage.glusterfs.add_bricks
       - require:
         - salt: glusterfs-peer   
{% else %}
glusterfs-volume:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NODE') }}
       - sls:
         - dev.storage.glusterfs.volume
       - require:
         - salt: glusterfs-peer
{% endif %}

{% elif salt['pillar.get']('basic:cinder:BACKENDS') == 'ceph' %}
ceph-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:storage-common:NODES') }}
       - tgt_type: list
       - sls:
         - dev.storage.ceph
       - require:
         - salt: hosts-init
{% endif %}
