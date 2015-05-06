{% set neutron_network_type = salt['pillar.get']('basic:neutron:NEUTRON_NETWORK_TYPE') %}
{% set data_interface = salt['pillar.get']('basic:neutron:DATA_INTERFACE') %}
{% set manage_interface = salt['pillar.get']('basic:neutron:MANAGE_INTERFACE') %}
{% set manage_ip = grains['ip_interfaces'].get(manage_interface,'') %}
{% set public_interface = salt['pillar.get']('basic:neutron:PUBLIC_INTERFACE') %}
{% set l3_enabled = salt['pillar.get']('basic:neutron:L3_ENABLED') %}

openvswitch-service:
  service.running:
    - name: openvswitch
    - enable: True

{% if l3_enabled %}
{% if neutron_network_type == 'vlan' %}
{% set br_list = ['br-int','br-data','br-ex'] %}
{% else %}
{% set br_list = ['br-int','br-ex'] %}
{% endif %}
{% else %}
{% set br_list = ['br-int','br-data'] %}
{% endif %}

{% for bridge in br_list %}
openvswitch-{{ bridge }}-bridge:
   cmd.run:
      - name: ovs-vsctl add-br {{ bridge }}
      - unless: ovs-vsctl list-br | grep {{ bridge }}
      - require:
        - service: openvswitch-service
{% endfor %}

{{ data_interface }}_interface_up:
   cmd.run:
      - name: ifconfig {{ data_interface }} up
      - unless: ip addr show {{ data_interface }} | grep -i up

{% if data_interface != manage_interface %}
add-data-interface-ip:
   cmd.run: 
      - name: ifconfig {{ data_interface }} {{ '10.10.10.' + manage_ip[0].split('.')[3] }}/24 
      - require:
        - cmd: {{ data_interface }}_interface_up
{% endif %}

{% if neutron_network_type == 'vlan' %}
openvswitch-br-data-port:
   cmd.run:
      - name: ovs-vsctl add-port br-data {{ data_interface }}
      - unless: ovs-vsctl list-ports br-data | grep {{ data_interface }}
      - require:
        - service: openvswitch-service
        - cmd: openvswitch-br-data-bridge
        - cmd: {{ data_interface }}_interface_up
{% endif %}

{% if l3_enabled %}
{{ public_interface }}_interface_up:
   cmd.run:
      - name: ifconfig {{ public_interface }} up
      - unless: ip addr show {{ public_interface }} | grep -i up

openvswitch-br-ex-port:
   cmd.run:
      - name: ovs-vsctl add-port br-ex {{ public_interface }}
      - unless: ovs-vsctl list-ports br-ex | grep {{ public_interface }}
      - require:
        - service: openvswitch-service
        - cmd: openvswitch-br-ex-bridge
        - cmd: {{ public_interface }}_interface_up
{% endif %}

neutron-server:
   service.running:
      - enable: True

{% if l3_enabled %}
{% set agent_list = ['dhcp','l3','lbaas','metadata','openvswitch'] %}
{% else %}
{% set agent_list = ['dhcp','openvswitch'] %}
{% endif %}

{% for agent in agent_list %}
neutron-{{agent}}-agent:
   service.running:
      - enable: True
      - watch:
        - service: neutron-server
{% if agent == 'openvswitch' %}
        - cmd: openvswitch-br-int-bridge
{% if l3_enabled %}
        - cmd: openvswitch-br-ex-port
{% endif %}
{% if neutron_network_type == 'vlan' %}
        - cmd: openvswitch-br-data-port
{% endif %}
{% endif %}
{% endfor %}
