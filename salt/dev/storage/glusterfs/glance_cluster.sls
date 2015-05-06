glance-peer-cluster:
  glusterfs.peered:
    - names:
{% if salt['pillar.get']('basic:nova:CONTROLLER:HOSTS',{}) %}
{% for hostname,ip in salt['pillar.get']('basic:nova:CONTROLLER:HOSTS',{}).items() %}
      - {{ hostname }}
{% endfor %}
{% endif %}
