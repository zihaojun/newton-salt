{% set storage_interface = salt['pillar.get']('basic:storage-common:STORAGE_INTERFACE') %}
{% set manage_interface = salt['pillar.get']('basic:neutron:MANAGE_INTERFACE') %}
{% set manage_ip = grains['ip_interfaces'].get(manage_interface,'') %}

/etc/sysconfig/network-scripts/ifcfg-{{storage_interface}}:
   file.managed:
      - source: salt://dev/storage/templates/ifcfg-eth.template
      - mode: 644
      - template: jinja
      - defaults:
        STORAGE_INTERFACE: {{ storage_interface }}
        STORAGE_IP: {{ '20.20.20.' + manage_ip[0].split('.')[3] }}

{{ storage_interface }}_interface_up:
   cmd.run:
      - name: ifconfig {{ storage_interface }} up
      - unless: ip addr show {{ storage_interface }}

add-storage-interface-ip:
   cmd.run:
      - name: ifconfig {{ storage_interface }} {{ '20.20.20.' + manage_ip[0].split('.')[3] }}/24
      - require:
        - cmd: {{ storage_interface }}_interface_up
