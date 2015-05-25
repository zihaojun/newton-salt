{% set storage_net = salt['pillar.get']('basic:storage-common:STORAGE_NET') %}
{% set storage_net_prefix = '.'.join(storage_net.split('.')[:-1]) %}
