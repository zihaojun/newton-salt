{% set VIP = salt['pillar.get']('basic:pacemaker:VIP') %}
{% set VIP_NIC = salt['pillar.get']('basic:pacemaker:VIP_NIC','eth0')  %}
{% set VIP_NETMASK = salt['pillar.get']('basic:pacemaker:VIP_NETMASK','24') %}
{% set VIP_PREFER_LOCATE = salt['pillar.get']('basic:pacemaker:VIP_PREFER_LOCATE') %}

crm-add-property:
   cmd.run:
      - names: 
#         - crm configure property stonith-enabled=false
         - crm configure property no-quorum-policy=ignore
         - crm configure property default-resource-stickiness=100

{% if not salt['pillar.get']('haproxy:ENABLE_KEEPALIVED') %}
crm-add-vip:
   cmd.run:
      - name: crm configure primitive VIP IPaddr2 params ip={{ VIP }} nic={{ VIP_NIC }} cidr_netmask={{ VIP_NETMASK}} meta target-role=Started op monitor interval=20s
      - unless: crm configure show | grep "primitive VIP IPaddr2" 

crm-add-vip-prefer-locate:
   cmd.run:
      - name: "crm configure location vip-prefer-locate VIP inf: {{ VIP_PREFER_LOCATE }}"
      - unless: crm configure show | grep "location vip-prefer-locate VIP"
      - watch:
        - cmd: crm-add-vip
{% endif %}
