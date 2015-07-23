{% if salt['pillar.get']('basic:nova:COMPUTE:INSTANCE_BACKENDS') == 'glusterfs' %}
create-volume:
  glusterfs.created:
    - name: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME','openstack') }}
    - bricks: 
{% if salt['pillar.get']('basic:storage-common:HOSTS:STORAGE',{}) %}
{% for hostname in salt['pillar.get']('basic:storage-common:HOSTS:STORAGE').keys() %}
      - {{ hostname }}:{{ salt['pillar.get']('basic:glusterfs:BRICKS','/usr/gluster') }}
{% endfor %}
{% endif %}
    - replica: {{ salt['pillar.get']('glusterfs:REPLICA',2) }}
    - transport: {{ salt['pillar.get']('glusterfs:TRANSPORT','tcp') }}
    - start: True

set-volume-property:
  glusterfs.set_volume_property:
    - name: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME','openstack') }}
    - key: group
    - value: virt
    - require:
      - glusterfs: create-volume
{% endif %}

{% if salt['pillar.get']('basic:glance:IMAGE_BACKENDS') == 'glusterfs' %}
create-glance-volume:
  glusterfs.created:
    - name: {{ salt['pillar.get']('basic:glance:VOLUME_NAME','glance') }}
    - bricks:
{% if salt['pillar.get']('basic:storage-common:HOSTS:CONTROLLER',{}) %}
{% for hostname in salt['pillar.get']('basic:storage-common:HOSTS:CONTROLLER').keys() %}
      - {{ hostname }}:{{ salt['pillar.get']('basic:glance:BRICKS','/usr/gluster') }}
{% endfor %}
{% endif %}
    - replica: {{ salt['pillar.get']('glusterfs:REPLICA',2) }}
    - transport: {{ salt['pillar.get']('glusterfs:TRANSPORT','tcp') }}
    - start: True

set-glance-volume-property:
  glusterfs.set_volume_property:
    - name: {{ salt['pillar.get']('basic:glance:VOLUME_NAME','glance') }}
    - key: group
    - value: virt
    - require:
      - glusterfs: create-glance-volume
{% endif %}

{% if salt['pillar.get']('basic:cinder:BACKENDS') == 'glusterfs' and 
   salt['pillar.get']('basic:cinder:VOLUME_NAME') != 
   salt['pillar.get']('basic:glusterfs:VOLUME_NAME') and 
   salt['pillar.get']('basic:cinder:VOLUME_NAME') !=
   salt['pillar.get']('basic:glance:VOLUME_NAME','glance') 
%}
create-cinder-volume:
  glusterfs.created:
    - name: {{ salt['pillar.get']('basic:cinder:VOLUME_NAME','cinder') }}
    - bricks:
{% if salt['pillar.get']('basic:storage-common:HOSTS:STORAGE',{}) %}
{% for hostname in salt['pillar.get']('basic:storage-common:HOSTS:STORAGE').keys() %}
      - {{ hostname }}:{{ salt['pillar.get']('basic:cinder:BRICKS','/usr/gluster') }}
{% endfor %}
{% endif %}
    - replica: {{ salt['pillar.get']('glusterfs:REPLICA',2) }}
    - transport: {{ salt['pillar.get']('glusterfs:TRANSPORT','tcp') }}
    - start: True

set-cinder-volume-property:
  glusterfs.set_volume_property:
    - name: {{ salt['pillar.get']('basic:cinder:VOLUME_NAME','cinder') }}
    - key: group
    - value: virt
    - require:
      - glusterfs: create-cinder-volume
{% endif %}
