libvirtd:
   service.running:
      - enable: True
      - watch:
        - service: messagebus

messagebus:
   service.running:
      - enable: True

openstack-nova-compute:
   service.running:
      - enable: True
      - watch:
        - service: libvirtd 

crond:
   service.running:
      - enable: True
