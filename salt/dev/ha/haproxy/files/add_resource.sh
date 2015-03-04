#!/bin/bash

crm configure primitive HAPROXY service:haproxy \
        meta target-role=Started \
        op monitor interval=20s

crm configure colocation vip-with-haproxy inf: VIP HAPROXY
crm configure order vip-before-haproxy Mandatory: VIP HAPROXY
