{% set storage_net = salt['pillar.get']('basic:storage-common:STORAGE_NET') %}
{% set storage_net_prefix = '.'.join(storage_net.split('.')[:-1]) %}
{% set storage_controller_host = salt['pillar.get']('basic:storage-common:HOSTS:CONTROLLER','')  %}
{% set storage_host = salt['pillar.get']('basic:storage-common:HOSTS:STORAGE','')  %}

{% if storage_host %}
{% set storage_all_host = storage_host.copy() %}
{% do storage_all_host.update(storage_controller_host) %}
{% else %}
{% if storage_controller_host %}
{% set storage_all_host = storage_controller_host.copy() %}
{% else %}
{% set storage_all_host = '' %}
{% endif %}
{% endif %}
