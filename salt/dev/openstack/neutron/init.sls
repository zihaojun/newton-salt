{% set NETWORK_ENABLED = salt['pillar.get']('basic:neutron:NETWORK_ENABLED') %}
{% set L3_ENABLED = salt['pillar.get']('basic:neutron:L3_ENABLED') %}
{% set manage_interface = salt['pillar.get']('basic:neutron:MANAGE_INTERFACE') %}
{% set data_interface = salt['pillar.get']('basic:neutron:DATA_INTERFACE') %}
{% set public_interface = salt['pillar.get']('basic:neutron:PUBLIC_INTERFACE') %}
{% set manage_ip = grains['ip_interfaces'].get(manage_interface,'') %}

neutron-init:
    pkg.installed:
       - pkgs:
         - openstack-neutron-ml2
         - openstack-neutron
         - python-neutronclient
         - haproxy
{% if NETWORK_ENABLED %}
         - openstack-neutron-openvswitch
{% endif %}

/etc/sysctl.d/99-salt.conf:
    file.touch

{% if NETWORK_ENABLED %}
{% for sys in ['default','all'] %}
net.ipv4.conf.{{ sys }}.rp_filter:
    sysctl.present:
       - value: 0
       - config: /etc/sysctl.conf
       - require:
         - file: /etc/sysctl.d/99-salt.conf
{% endfor %}
net.ipv4.ip_forward:
    sysctl.present:
       - value: 1
       - config: /etc/sysctl.conf
       - require:
         - file: /etc/sysctl.d/99-salt.conf
{% endif %}

/etc/neutron/neutron.conf:
     file.managed:
        - source: salt://dev/openstack/neutron/templates/neutron.conf.controller.template
        - mode: 644
        - user: neutron
        - group: neutron
        - template: jinja
        - require:
          - pkg: neutron-init
        - defaults:
          IPADDR: {{ grains['host'] }}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
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
        - require:
          - pkg: neutron-init

{% if data_interface != manage_interface %}
/etc/sysconfig/network-scripts/ifcfg-{{data_interface}}:
   file.managed:
      - source: salt://dev/openstack/neutron/templates/ifcfg-eth.template
      - mode: 644
      - template: jinja
      - defaults:
        DATA_INTERFACE: {{ data_interface }}
        DATA_IP: {{ '10.10.10.' + manage_ip[0].split('.')[3] }} 
{% endif %}

{% if L3_ENABLED %}
{% if public_interface != manage_interface %}
/etc/sysconfig/network-scripts/ifcfg-{{public_interface}}:
   file.managed:
      - source: salt://dev/openstack/neutron/templates/ifcfg-public-interface.template 
      - mode: 644
      - template: jinja
      - defaults:
        PUBLIC_INTERFACE: {{ public_interface }}
{% endif %}
{% endif %}

/etc/neutron/plugins/ml2/ml2_conf.ini:
   file.managed:
      - source: salt://dev/openstack/neutron/templates/ml2_conf.ini.template
      - mode: 644
      - user: neutron
      - group: neutron
      - require:
        - pkg: neutron-init
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


/etc/neutron/plugin.ini:
   file.symlink:
      - target: /etc/neutron/plugins/ml2/ml2_conf.ini
      - require:
        - pkg: neutron-init


{% for agent in ['dhcp','l3','lbaas','metadata'] %}
/etc/neutron/{{agent}}_agent.ini:
   file.managed:
      - source: salt://dev/openstack/neutron/templates/{{agent}}_agent.ini.template
      - mode: 640
      - user: neutron
      - group: neutron
      - require:
        - pkg: neutron-init
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


/usr/lib/systemd/system/neutron-openvswitch-agent.service:
   file.replace:
      - pattern: plugins/openvswitch/ovs_neutron_plugin.ini
      - repl: plugin.ini
      - require:
        - pkg: neutron-init
