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
{% set br_list = ['br-int','bond-br','br-ex'] %}
{% else %}
{% set br_list = ['br-int','br-ex'] %}
{% endif %}
{% else %}
{% set br_list = ['br-int','bond-br'] %}
{% endif %}

{% for bridge in br_list %}
openvswitch-{{ bridge }}-bridge:
   cmd.run:
      - name: ovs-vsctl add-br {{ bridge }}
      - unless: ovs-vsctl list-br | grep {{ bridge }}
      - require:
        - service: openvswitch-service
{% endfor %}

{{ data_interface }}_data_interface_up:
   cmd.run:
      - name: ifconfig {{ data_interface }} up
      - unless: ip addr show {{ data_interface }} | grep -i up

{% if data_interface != manage_interface and neutron_network_type != 'vlan' %}
add-data-interface-ip:
   cmd.run: 
      - name: ifconfig {{ data_interface }} {{ '10.10.10.' + manage_ip[0].split('.')[3] }} netmask 255.255.255.0
      - require:
        - cmd: {{ data_interface }}_data_interface_up
{% endif %}

{% if neutron_network_type == 'vlan' %}
openvswitch-bond-br-port:
   cmd.run:
      - name: ovs-vsctl add-port bond-br {{ data_interface }}
      - unless: ovs-vsctl list-ports bond-br | grep {{ data_interface }}
      - require:
        - service: openvswitch-service
        - cmd: openvswitch-bond-br-bridge
        - cmd: {{ data_interface }}_data_interface_up
{% endif %}

{% if l3_enabled %}
{{ public_interface }}_public_interface_up:
   cmd.run:
      - name: ifconfig {{ public_interface }} up
      - unless: ip addr show {{ public_interface }} | grep -i up

{% if public_interface != manage_interface %}
openvswitch-br-ex-port:
   cmd.run:
      - name: ovs-vsctl add-port br-ex {{ public_interface }}
      - unless: ovs-vsctl list-ports br-ex | grep {{ public_interface }}
      - require:
        - service: openvswitch-service
        - cmd: openvswitch-br-ex-bridge
        - cmd: {{ public_interface }}_public_interface_up
{% endif %}
{% endif %}

neutron-server:
   service.running:
      - enable: True
      - watch:
        - file: /etc/neutron/neutron.conf
        - file: /etc/neutron/dnsmasq-neutron.conf
        - file: /etc/neutron/plugins/ml2/ml2_conf.ini 

/etc/neutron/neutron.conf:
     file.managed:
        - source: salt://dev/openstack/neutron/templates/neutron.conf.controller.template
        - mode: 644
        - user: neutron
        - group: neutron
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_1') + ':5672,' + salt['pillar.get']('basic:corosync:NODE_2') + ':5672' }}
{% else %}
          VIP: {{ grains['host'] }}
          RABBIT: {{ grains['host'] + ':5672' }}
{% endif %}
          RABBIT_USER: {{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}
          RABBIT_PASS: {{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}
          SERVICE_TENANT_ID: {{ salt['mysql.query']('keystone',"select id from project where name='service'")['results'][0][0] }}
          AUTH_ADMIN_NOVA_USER: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_USER') }}
          AUTH_ADMIN_NOVA_PASS: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_PASS') }}
          MYSQL_NEUTRON_USER: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_USER') }}
          MYSQL_NEUTRON_PASS: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_PASS') }}
          MYSQL_NEUTRON_DBNAME: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_DBNAME') }}
          AUTH_ADMIN_NEUTRON_USER: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_USER') }}
          AUTH_ADMIN_NEUTRON_PASS: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_PASS') }}

/etc/neutron/dnsmasq-neutron.conf:
     file.managed:
        - source: salt://dev/openstack/neutron/files/dnsmasq-neutron.conf
        - mode: 644
        - user: neutron
        - group: neutron

/etc/neutron/plugins/ml2/ml2_conf.ini:
   file.managed:
      - source: salt://dev/openstack/neutron/templates/ml2_conf.ini.template
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

{% for agent in ['dhcp','l3','lbaas','metadata'] %}
/etc/neutron/{{agent}}_agent.ini:
   file.managed:
      - source: salt://dev/openstack/neutron/templates/{{agent}}_agent.ini.template
      - mode: 640
      - user: neutron
      - group: neutron
{% if agent == 'metadata' %}
      - template: jinja
      - defaults:
         IPADDR: {{ grains['host'] }}
         VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
         AUTH_ADMIN_NEUTRON_USER: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_USER') }}
         AUTH_ADMIN_NEUTRON_PASS: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_PASS') }}
         METADATA_PROXY_SECRET: {{ salt['pillar.get']('nova:METADATA_PROXY_SECRET') }}
{% endif %}
{% endfor %}

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
        - file: /etc/neutron/plugins/ml2/ml2_conf.ini
{% if l3_enabled and public_interface != manage_interface %}
        - cmd: openvswitch-br-ex-port
{% endif %}
{% if neutron_network_type == 'vlan' %}
        - cmd: openvswitch-bond-br-port
{% endif %}
{% elif agent == 'dhcp' %}
        - file: /etc/neutron/dhcp_agent.ini
{% elif agent == 'l3' %}
        - file: /etc/neutron/l3_agent.ini
{% elif agent == 'lbaas' %}
        - file: /etc/neutron/lbaas_agent.ini
{% elif agent == 'metadata' %}
        - file: /etc/neutron/metadata_agent.ini
{% endif %}
        - file: /etc/neutron/neutron.conf
{% endfor %}
