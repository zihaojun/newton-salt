{% set neutron_network_type = salt['pillar.get']('basic:neutron:NEUTRON_NETWORK_TYPE') %}
{% set data_interface = salt['pillar.get']('basic:neutron:DATA_INTERFACE') %}
{% set manage_interface = salt['pillar.get']('basic:neutron:MANAGE_INTERFACE') %}
{% set manage_ip = grains['ip_interfaces'].get(manage_interface,'') %}

openvswitch:
   service.running:
      - enable: True

{% if neutron_network_type == 'vlan' %}
{% set br_list = ['br-int','br-data'] %}
{% else %}
{% set br_list = ['br-int'] %}
{% endif %}

{{ data_interface }}_interface_up:
   cmd.run:
      - name: ifconfig {{ data_interface }} up
      - unless: ip addr show {{ data_interface }}

{% if data_interface != manage_interface %}
add-data-interface-ip:
   cmd.run:
      - name: ifconfig {{ data_interface }} {{ '10.10.10.' + manage_ip[0].split('.')[3] }}/24
      - require:
        - cmd: {{ data_interface }}_interface_up
{% endif %}

{% for bridge in br_list %}
openvswitch-{{ bridge }}-bridge:
   cmd.run:
      - name: ovs-vsctl add-br {{ bridge }}
      - unless: ovs-vsctl list-br | grep {{ bridge }}
      - require:
        - service: openvswitch
{% endfor %}

{% if neutron_network_type == 'vlan' %}
openvswitch-br-data-port:
   cmd.run:
      - name: ovs-vsctl add-port br-data {{ data_interface }}
      - unless: ovs-vsctl list-ports br-data | grep {{ data_interface }}
      - require:
        - service: openvswitch
        - cmd: openvswitch-br-data-bridge
        - cmd: {{ data_interface }}_interface_up
{% endif %}

neutron-openvswitch-agent:
   service.running:
      - enable: True
      - watch:
        - cmd: openvswitch-br-int-bridge
{% if neutron_network_type == 'vlan' %}
        - cmd: openvswitch-br-data-port
{% endif %}
