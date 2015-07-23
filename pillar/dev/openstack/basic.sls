config_cinder_install: True
config_heat_install: True 
config_ceilometer_install: True
config_logstash_install: False
config_compute_install: True
config_storage_install: True
config_ha_install: True
config_enable_iptables: False
config_enable_os_security: False

keystone.endpoint: 'http://controller-20:35357/v2.0'

basic:
   rabbitmq:
      DISC_NODE: controller-20
      RAM_NODE: controller-21
  
   mariadb:
      MASTER: controller-20
      SLAVE: controller-21
 
   mongodb:
      MASTER: controller-20
      SLAVE: controller-21

   influxdb:
      MASTER: controller-20
      SLAVE: controller-21

   corosync:
      HEARTBEAT_NET: 90.90.90.0
      NODES: controller-20,controller-21
      NODE_1: controller-20
      NODE_2: controller-21

   pacemaker:
      VIP: 90.90.90.30
      VIP_HOSTNAME: controller
      VIP_NETMASK: 24
      VIP_NIC: eth0
      VIP_PREFER_LOCATE: controller-20

   storage-common:
      HOSTS: 
        CONTROLLER:
           controller-20: 90.90.90.20
           controller-21: 90.90.90.21
        STORAGE:  
       
      NODES: node-14,node-13
      MANAGE_HOSTNAME_PREFIX: compute-
      STORAGE_NET: 172.16.100.0
      ENABLE_COMPUTE: True
      ADD_NODE_ENABLED: False
      STORAGE_INTERFACE: eth0

   glusterfs:
      VOLUME_NODE: controller-21
      VOLUME_NAME: nova 
      BRICKS: /gfs/gluster
      MOUNT_OPT: backup-volfile-servers=node-13 # use ':' to seperate

   glance:
      IMAGE_BACKENDS: glusterfs   # optional configuration: local|glusterfs    
      VOLUME_NAME: glance
      BRICKS: /gfs/gfs

   nova:
      CONTROLLER:
        COMPUTE_ENABLED: True 
        HOSTS:
          controller-20: 90.90.90.20
          controller-21: 90.90.90.21
    
      COMPUTE:
        HOSTS:
          compute-22: 90.90.90.22
          compute-23: 90.90.90.23
          compute-24: 90.90.90.24
          compute-25: 90.90.90.25
        INSTANCE_BACKENDS: local   # optional configuration: local|glusterfs
        NODES: compute-22,compute-23,compute-24,compute-25 
        ADD_NODE_ENABLED: False 
  
   neutron:
      NEUTRON_NETWORK_TYPE: vlan  # optional configuration: vlan|gre|vxlan
      NETWORK_VLAN_RANGES: 3:10
      TUNNEL_ID_RANGES: 1:1000
      NETWORK_ENABLED: True
      PUBLIC_INTERFACE: eth1
      L3_ENABLED: False
      DATA_INTERFACE: eth0
      MANAGE_INTERFACE: eth0

   cinder:
      BACKENDS: glusterfs  # optional backends: none,glusterfs,lvm or ceph.only support glusterfs、lvm now.
      VOLUME_NAME: glance
      BRICKS: /cinder/gfs
      VOLUME_URL: localhost:/glance

   horizon:
      ANIMBUS_ENABLED: True
