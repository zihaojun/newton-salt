crm-add-haproxy:
   cmd.run:
      - name: crm configure primitive HAPROXY service:haproxy meta target-role=Started op monitor interval=20s 
      - unless: crm configure show | grep "HAPROXY service"

crm-add-vip-with-haproxy:
   cmd.run:
      - name: "crm configure colocation vip-with-haproxy inf: VIP HAPROXY"
      - unless: crm configure show | grep "colocation vip-with-haproxy"
      - watch:
        - cmd: crm-add-haproxy

crm-add-vip-before-haproxy:
   cmd.run:
      - name: "crm configure order vip-before-haproxy Mandatory: VIP HAPROXY"
      - unless: crm configure show | grep "order vip-before-haproxy"
      - watch:
        - cmd: crm-add-vip-with-haproxy

