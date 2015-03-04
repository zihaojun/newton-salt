neutron:
    NEUTRON_NETWORK_TYPE: vxlan  # optional configuration: vlan|gre|vxlan
    NETWORK_VLAN_RANGES: 101:130
    TUNNEL_ID_RANGES: 1:1000
    MYSQL_NEUTRON_USER: neutron
    MYSQL_NEUTRON_PASS: neutron
    MYSQL_NEUTRON_DBNAME: neutron
    AUTH_ADMIN_NEUTRON_USER: neutron
    AUTH_ADMIN_NEUTRON_PASS: neutron
    NETWORK_ENABLED: True
    PUBLIC_INTERFACE: eth1
    L3_ENABLED: False
    DATA_INTERFACE: eth1
    MANAGE_INTERFACE: eth0
