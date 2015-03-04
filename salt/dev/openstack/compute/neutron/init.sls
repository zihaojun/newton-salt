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
        - pkg: neutron-compute-install

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
      - source: salt://openstack/neutron/templates/neutron.conf.compute.template
      - mode: 644
      - user: neutron
      - group: neutron
      - require:
        - pkg: neutron-compute-install
      - template: jinja
      - defaults:

/etc/neutron/plugins/ml2/ml2_conf.ini:
   file.managed:
      - source: salt://openstack/neutron/templates/ml2_conf.ini.template
      - mode: 644
      - user: neutron
      - group: neutron
      - require:
        - pkg: neutron-compute-install
      - template: jinja
      - defaults:
          NEUTRON_NETWORK_TYPE: {{ pillar['config']['NEUTRON']['NEUTRON_NETWORK_TYPE'] }}
          NETWORK_VLAN_RANGES: {{ pillar['config']['NEUTRON'].get('NETWORK_VLAN_RANGES') }}
          TUNNEL_ID_RANGES: {{ pillar['config']['NEUTRON'].get('TUNNEL_ID_RANGES') }}
         {% if data_ip %}
          LOCAL_IP: {{ data_ip[0] }}
         {% else %}
          LOCAL_IP: {{ 'None' }}
         {% endif %}

/etc/neutron/plugin.ini:
   file.symlink:
      - target: /etc/neutron/plugins/ml2/ml2_conf.ini
      - require:
        - pkg: neutron-compute-install

/usr/lib/systemd/system/neutron-openvswitch-agent.service:
   file.replace:
      - pattern: plugins/openvswitch/ovs_neutron_plugin.ini
      - repl: plugin.ini
      - require:
        - pkg: neutron-compute-install
