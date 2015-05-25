{% set storage_hostname_prefix = salt['pillar.get']('basic:storage-common:STORAGE_HOSTNAME_PREFIX')  %}


{{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }}:
    glusterfs.add_volume_bricks:
         -  bricks:
{% for host in salt['pillar.get']('basic:storage-common:NODES').split(',') %} 
            - {{ 'gluster-' + host.split(storage_hostname_prefix)[1] }}:{{ salt['pillar.get']('basic:glusterfs:BRICKS','/usr/gluster') }}
{% endfor %}
