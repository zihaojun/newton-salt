glance-create-volume:
  glusterfs.created:
    - name: glance 
    - bricks: 
{% if salt['pillar.get']('basic:nova:CONTROLLER:HOSTS',{}) %}
{% for hostname in salt['pillar.get']('basic:nova:CONTROLLER:HOSTS').keys() %}
      - {{ hostname }}:{{ salt['pillar.get']('basic:glusterfs:BRICKS','/usr/gluster') }}
{% endfor %}
{% endif %}
    - replica: {{ salt['pillar.get']('glusterfs:REPLICA',2) }}
    - transport: {{ salt['pillar.get']('glusterfs:TRANSPORT','tcp') }}
    - start: True 
