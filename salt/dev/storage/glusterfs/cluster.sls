{% from 'dev/storage/var.sls' import storage_all_host with context %}

peer-cluster:
  glusterfs.peered:
    - names:
{% if storage_all_host %}
{% for hostname,ip in storage_all_host.items() %}
      - {{ hostname }}
{% endfor %}
{% endif %}
