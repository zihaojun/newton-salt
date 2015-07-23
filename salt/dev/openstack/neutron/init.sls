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

salt://dev/openstack/neutron/files/neutron-db.sh:
    cmd.script:
        - template: jinja
        - require:
          - pkg: neutron-init
        - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
{% else %}
          VIP: {{ grains['host'] }}
{% endif %}
          MYSQL_NEUTRON_USER: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_USER') }}
          MYSQL_NEUTRON_PASS: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_PASS') }}
          MYSQL_NEUTRON_DBNAME: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_DBNAME') }}
        - env:
          - BATCH: 'yes'

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

/etc/neutron/plugin.ini:
   file.symlink:
      - target: /etc/neutron/plugins/ml2/ml2_conf.ini
      - require:
        - pkg: neutron-init


/usr/lib/systemd/system/neutron-openvswitch-agent.service:
   file.replace:
      - pattern: plugins/openvswitch/ovs_neutron_plugin.ini
      - repl: plugin.ini
      - require:
        - pkg: neutron-init
