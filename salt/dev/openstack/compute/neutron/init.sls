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
