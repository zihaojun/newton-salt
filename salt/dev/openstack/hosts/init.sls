{% set storage_interface = salt['pillar.get']('basic:storage-common:STORAGE_INTERFACE') %}
{% set manage_interface = salt['pillar.get']('basic:neutron:MANAGE_INTERFACE') %}
{% from 'dev/storage/var.sls' import storage_all_host with context %}

os-util-pkg:
   pkg.installed:
      - pkgs:
        - net-tools

/etc/hosts:
   file.managed:
      - source: salt://dev/openstack/hosts/templates/hosts.template
      - template: jinja
      - defaults:
{% if salt['pillar.get']('config_compute_install',False) %}
        COMPUTE_HOSTS: {{ salt['pillar.get']('basic:nova:COMPUTE:HOSTS','') }}
{% else %}
        COMPUTE_HOSTS: {{ '' }} 
{% endif %}
        CONTROLLER_HOSTS: {{ salt['pillar.get']('basic:nova:CONTROLLER:HOSTS','') }}
{% if salt['pillar.get']('config_storage_install',False) %}
        STORAGE_HOSTS: {{ storage_all_host }}
{% else %}
        STORAGE_HOSTS: {{ '' }}
{% endif %}
{% if storage_interface == manage_interface %}
        STORAGE_INTERFACE_EQUAL_MANAGE: {{ True }}
{% else %}
        STORAGE_INTERFACE_EQUAL_MANAGE: {{ False }}
{% endif %}

{% if salt['pillar.get']('config_ha_install',False) %}
add-vip-hosts:
   host.present:
       - name: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
       - ip: {{ salt['pillar.get']('basic:pacemaker:VIP') }}
       - require: 
         - file: /etc/hosts
{% endif %}
