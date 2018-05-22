public_password: openstack

nova:
    CONTROLLER: controller
    CONTROLLER_IP: 10.0.0.133
    PUBLIC_ADDR: 192.168.247.138
    HOSTS:
      contoller: 10.0.0.133

neutron:
    NET: 10.0.0.0/24   
    MANAGE_INTERFACE: eth1

storage:
    TYPE: glusterfs
    VGNAME: gfs
    VGDEVS:
    HARDNAME:

compute:
    ENABLED: False
    COMPUTE: controller
    COMPUTE_IP: 10.0.0.133
