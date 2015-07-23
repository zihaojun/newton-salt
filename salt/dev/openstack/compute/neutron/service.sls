{% set neutron_network_type = salt['pillar.get']('basic:neutron:NEUTRON_NETWORK_TYPE') %}
{% set data_interface = salt['pillar.get']('basic:neutron:DATA_INTERFACE') %}
{% set manage_interface = salt['pillar.get']('basic:neutron:MANAGE_INTERFACE') %}
{% set manage_ip = grains['ip_interfaces'].get(manage_interface,'') %}

openvswitch:
   service.running:
      - enable: True

{% if neutron_network_type == 'vlan' %}
{% set br_list = ['br-int','bond-br'] %}
{% else %}
{% set br_list = ['br-int'] %}
{% endif %}

{{ data_interface }}_interface_up:
   cmd.run:
      - name: ifconfig {{ data_interface }} up
      - unless: ip addr show {{ data_interface }} | grep -i up

{% if data_interface != manage_interface and neutron_network_type != 'vlan' %}
add-data-interface-ip:
   cmd.run:
      - name: ifconfig {{ data_interface }} {{ '10.10.10.' + manage_ip[0].split('.')[3] }} netmask 255.255.255.0
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
openvswitch-bond-br-port:
   cmd.run:
      - name: ovs-vsctl add-port bond-br {{ data_interface }}
      - unless: ovs-vsctl list-ports bond-br | grep {{ data_interface }}
      - require:
        - service: openvswitch
        - cmd: openvswitch-bond-br-bridge
        - cmd: {{ data_interface }}_interface_up
{% endif %}

neutron-openvswitch-agent:
   service.running:
      - enable: True
      - watch:
        - cmd: openvswitch-br-int-bridge
        - file: /etc/neutron/neutron.conf
        - file: /etc/neutron/plugins/ml2/ml2_conf.ini
{% if neutron_network_type == 'vlan' %}
        - cmd: openvswitch-bond-br-port
{% endif %}

/etc/neutron/neutron.conf:
   file.managed:
      - source: salt://dev/openstack/compute/neutron/templates/neutron.conf.compute.template
      - mode: 644
      - user: neutron
      - group: neutron
      - template: jinja
      - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
        RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_1') + ':5672,' + salt['pillar.get']('basic:corosync:NODE_2') + ':5672' }}
{% else %}
        VIP: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
        RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_1') + ':5672' }}
{% endif %}
        RABBIT_USER: {{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}
        RABBIT_PASS: {{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}
        MYSQL_NEUTRON_USER: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_USER') }}
        MYSQL_NEUTRON_PASS: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_PASS') }}
        MYSQL_NEUTRON_DBNAME: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_DBNAME') }}
        AUTH_ADMIN_NEUTRON_USER: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_USER') }}
        AUTH_ADMIN_NEUTRON_PASS: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_PASS') }}

/etc/neutron/plugins/ml2/ml2_conf.ini:
   file.managed:
      - source: salt://dev/openstack/compute/neutron/templates/ml2_conf.ini.template
      - mode: 644
      - user: neutron
      - group: neutron
      - template: jinja
      - defaults:
          NEUTRON_NETWORK_TYPE: {{ salt['pillar.get']('basic:neutron:NEUTRON_NETWORK_TYPE') }}
          NETWORK_VLAN_RANGES: {{ salt['pillar.get']('basic:neutron:NETWORK_VLAN_RANGES') }}
          TUNNEL_ID_RANGES: {{ salt['pillar.get']('basic:neutron:TUNNEL_ID_RANGES') }}
          {% if data_interface == manage_interface %}
          LOCAL_IP: {{ manage_ip[0] }}
         {% elif data_interface != manage_interface %}
          LOCAL_IP: {{ '10.10.10.' + manage_ip[0].split('.')[3] }}
         {% else %}
          LOCAL_IP: {{ 'None' }}
         {% endif %}
