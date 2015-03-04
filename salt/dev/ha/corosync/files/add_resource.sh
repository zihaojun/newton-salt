#!/bin/bash

crm configure property stonith-enabled=false
crm configure property no-quorum-policy=ignore
crm configure property default-resource-stickiness=100
{% if not ENABLE_KEEPALIVED %}
crm configure primitive VIP IPaddr2 \
	params ip={{ VIP }} nic={{ VIP_NIC }} cidr_netmask={{ VIP_NETMASK}} \
	meta target-role=Started \
	op monitor interval=20s

crm configure location vip-prefer-locate VIP inf: {{ VIP_PREFER_LOCATE }}
{% endif %}
