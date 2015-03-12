{{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }}:
    glusterfs.add_volume_bricks:
         -  bricks:
{% for host in salt['pillar.get']('basic:storage-common:NODES').split(',') %} 
            - {{host}}:{{ salt['pillar.get']('basic:glusterfs:BRICKS','/usr/gluster') }}
{% endfor %}
