{% set manage_interface = salt['pillar.get']('basic:neutron:MANAGE_INTERFACE') %}
{% set data_interface = salt['pillar.get']('basic:neutron:DATA_INTERFACE') %}
{% set manage_ip = grains['ip_interfaces'].get(manage_interface,'') %}
neutron-compute-init:
    pkg.installed:
       - pkgs:
         - openstack-neutron-ml2
         - openstack-neutron-openvswitch

/var/log/openvswitch:
   file.directory:
      - user: root
      - group: root
      - require:
        - pkg: neutron-compute-init

/etc/sysctl.d/99-salt.conf:
    file.touch

{% for sys in ['default','all'] %}
net.ipv4.conf.{{ sys }}.rp_filter:
    sysctl.present:
       - value: 0
       - config: /etc/sysctl.conf
       - require:
         - file: /etc/sysctl.d/99-salt.conf
{% endfor %}

/etc/neutron/neutron.conf:
   file.managed:
      - source: salt://dev/openstack/compute/neutron/templates/neutron.conf.compute.template
      - mode: 644
      - user: neutron
      - group: neutron
      - require:
        - pkg: neutron-compute-init
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
        MYSQL_NEUTRON_USER: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_USER') }}
        MYSQL_NEUTRON_PASS: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_PASS') }}
        MYSQL_NEUTRON_DBNAME: {{ salt['pillar.get']('neutron:MYSQL_NEUTRON_DBNAME') }}
        AUTH_ADMIN_NEUTRON_USER: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_USER') }}
        AUTH_ADMIN_NEUTRON_PASS: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_PASS') }}

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


/etc/neutron/plugins/ml2/ml2_conf.ini:
   file.managed:
      - source: salt://dev/openstack/compute/neutron/templates/ml2_conf.ini.template
      - mode: 644
      - user: neutron
      - group: neutron
      - require:
        - pkg: neutron-compute-init
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
        - pkg: neutron-compute-init

/usr/lib/systemd/system/neutron-openvswitch-agent.service:
   file.replace:
      - pattern: plugins/openvswitch/ovs_neutron_plugin.ini
      - repl: plugin.ini
      - require:
        - pkg: neutron-compute-init
