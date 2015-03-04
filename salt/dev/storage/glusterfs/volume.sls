create-volume:
  glusterfs.created:
    - name: {{ salt['pillar.get']('glusterfs:VOLUME_NAME','openstack') }}
    - bricks: 
{% if salt['pillar.get']('storage-common:HOSTS',{}) %}
{% for hostname in salt['pillar.get']('storage-common:HOSTS').keys() %}
      - {{ hostname }}:{{ salt['pillar.get']('glusterfs:BRICKS','/usr/gluster') }}
{% endfor %}
{% endif %}
    - replica: {{ salt['pillar.get']('glusterfs:REPLICA',2) }}
    - transport: {{ salt['pillar.get']('glusterfs:TRANSPORT','tcp') }}
    - start: True 
                             
