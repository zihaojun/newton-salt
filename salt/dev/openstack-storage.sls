{% set storage_interface = salt['pillar.get']('basic:storage-common:STORAGE_INTERFACE') %}
{% set manage_interface = salt['pillar.get']('basic:neutron:MANAGE_INTERFACE') %}

{% if storage_interface != manage_interface %}
storage-net-init:
   salt.state:
{% if salt['pillar.get']('config_compute_install',False) %}
{% if salt['pillar.get']('basic:storage-common:ENABLE_COMPUTE',False) %}
       - tgt: {{ salt['pillar.get']('basic:storage-common:NODES') }},{{ salt['pillar.get']('basic:corosync:NODES') }} 
{% else %}
       - tgt: {{ salt['pillar.get']('basic:storage-common:NODES') }},{{ salt['pillar.get']('basic:corosync:NODES') }},{{ salt['pillar.get']('basic:nova:COMPUTE:NODES') }}
{% endif %}
{% else %}
       - tgt: {{ salt['pillar.get']('basic:storage-common:NODES') }},{{ salt['pillar.get']('basic:corosync:NODES') }}
{% endif %}
       - tgt_type: list
       - sls:
         - dev.storage.common
{% endif %}


{% if salt['pillar.get']('basic:cinder:BACKENDS') == 'glusterfs' or 
   salt['pillar.get']('basic:glance:IMAGE_BACKENDS') == 'glusterfs' or 
   salt['pillar.get']('basic:nova:COMPUTE::INSTANCE_BACKENDS') == 'glusterfs'
%}
glusterfs-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:storage-common:NODES','') }}
       - tgt_type: list
       - sls:
         - dev.storage.glusterfs
       - require:
         - salt: hosts-init
{% if storage_interface != manage_interface %}
         - salt: storage-net-init
{% endif %}

glance-glusterfs-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.storage.glusterfs.pkg
       - require:
         - salt: hosts-init
{% if storage_interface != manage_interface %}
         - salt: storage-net-init
{% endif %}

glusterfs-peer:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NODE') }}
       - sls:
         - dev.storage.glusterfs.cluster
       - require:
         - salt: glusterfs-init
         - salt: glance-glusterfs-init

{% if salt['pillar.get']('basic:storage-common:ADD_NODE_ENABLED',False) %}
glusterfs-volume-add-bricks:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NODE') }} 
       - sls:
         - dev.storage.glusterfs.add_bricks
       - require:
         - salt: glusterfs-peer   
{% if storage_interface != manage_interface %}
         - salt: storage-net-init
{% endif %}
{% else %}
glusterfs-volume:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NODE') }}
       - sls:
         - dev.storage.glusterfs.volume
       - require:
         - salt: glusterfs-peer
{% endif %}
{% endif %}

{% if salt['pillar.get']('basic:cinder:BACKENDS') == 'ceph' %}
ceph-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:storage-common:NODES') }}
       - tgt_type: list
       - sls:
         - dev.storage.ceph
       - require:
         - salt: hosts-init
{% endif %}
