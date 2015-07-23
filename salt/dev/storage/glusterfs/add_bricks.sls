{% set manage_hostname_prefix = salt['pillar.get']('basic:storage-common:MANAGE_HOSTNAME_PREFIX')  %}

{{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }}:
    glusterfs.add_volume_bricks:
         - bricks:
{% for host in salt['pillar.get']('basic:storage-common:NODES').split(',') %} 
            - {{ 'gluster-' + host.split(manage_hostname_prefix)[1] }}:{{ salt['pillar.get']('basic:glusterfs:BRICKS','/usr/gluster') }}
{% endfor %}

{{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }}-rebalance:
    glusterfs.rebalance_volume:
         - name: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }}
         - require:
           - glusterfs: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }}

{% if salt['pillar.get']('basic:cinder:BACKENDS') == 'glusterfs' and
   salt['pillar.get']('basic:cinder:VOLUME_NAME') !=
   salt['pillar.get']('basic:glusterfs:VOLUME_NAME')
%}
{{ salt['pillar.get']('basic:cinder:VOLUME_NAME') }}:
    glusterfs.add_volume_bricks:
         -  bricks:
{% for host in salt['pillar.get']('basic:storage-common:NODES').split(',') %}
            - {{ 'gluster-' + host.split(manage_hostname_prefix)[1] }}:{{ salt['pillar.get']('basic:cinder:BRICKS','/usr/gluster') }}
{% endfor %}

{{ salt['pillar.get']('basic:cinder:VOLUME_NAME') }}-rebalance:
    glusterfs.rebalance_volume:
         - name: {{ salt['pillar.get']('basic:cinder:VOLUME_NAME') }}
         - require:
           - glusterfs: {{ salt['pillar.get']('basic:cinder:VOLUME_NAME') }}

{% endif %}
