{% set storage_interface = salt['pillar.get']('basic:storage-common:STORAGE_INTERFACE') %}
{% set manage_interface = salt['pillar.get']('basic:neutron:MANAGE_INTERFACE') %}

os-util-pkg:
   pkg.installed:
      - pkgs:
        - net-tools

/etc/hosts:
   file.managed:
      - source: salt://dev/openstack/hosts/templates/hosts.template
      - template: jinja
      - defaults:
        COMPUTE_HOSTS: {{ salt['pillar.get']('basic:nova:COMPUTE:HOSTS','') }}
        CONTROLLER_HOSTS: {{ salt['pillar.get']('basic:nova:CONTROLLER:HOSTS','') }}
        STORAGE_HOSTS: {{ salt['pillar.get']('basic:storage-common:HOSTS','') }}
{% if storage_interface == manage_interface %}
        STORAGE_INTERFACE_EQUAL_MANAGE: {{ True }}
{% else %}
        STORAGE_INTERFACE_EQUAL_MANAGE: {{ False }}
{% endif %}

add-vip-hosts:
   host.present:
       - name: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
       - ip: {{ salt['pillar.get']('basic:pacemaker:VIP') }}
       - require: 
         - file: /etc/hosts
