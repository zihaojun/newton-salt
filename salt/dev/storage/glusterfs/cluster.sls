peer-cluster:
  glusterfs.peered:
    - names:
{% if salt['pillar.get']('basic:storage-common:HOSTS',{}) %}
{% for hostname,ip in salt['pillar.get']('basic:storage-common:HOSTS',{}).items() %}
      - {{ hostname }}
{% endfor %}
{% endif %}

