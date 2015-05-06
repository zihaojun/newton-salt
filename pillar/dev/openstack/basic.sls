config_cinder_install: True
config_heat_install: True 
config_ceilometer_install: True
config_logstash_install: True
config_compute_install: False 

keystone.endpoint: 'http://node-6:35357/v2.0'

basic:
   rabbitmq:
      DISC_NODE: node-6
      RAM_NODE: node-7
  
   mariadb:
      MASTER: node-6
      SLAVE: node-7
 
   mongodb:
      MASTER: node-6
      SLAVE: node-7

   corosync:
      HEARTBEAT_NET: 192.168.200.0
      NODES: node-6,node-7
      NODE_1: node-6
      NODE_2: node-7

   pacemaker:
      VIP: 192.168.200.20
      VIP_HOSTNAME: controller
      VIP_NETMASK: 24
      VIP_NIC: eth0
      VIP_PREFER_LOCATE: node-6

   storage-common:
      HOSTS: 
        gluster-1: 20.20.20.13
        gluster-2: 20.20.20.14
       
      NODES: node-14,node-13
      ENABLE_COMPUTE: True
      ADD_NODE_ENABLED: False
      STORAGE_INTERFACE: eth2

   glusterfs:
      VOLUME_NODE: node-14
      VOLUME_NAME: openstack
      BRICKS: /gfs/gluster
      MOUNT_OPT: backup-volfile-servers=node-13

   glance:
      IMAGE_BACKENDS: glusterfs   # optional configuration: local|glusterfs    

   nova:
      CONTROLLER:
        HOSTS:
          node-6: 192.168.200.6
          node-7: 192.168.200.7
    
      COMPUTE:
        HOSTS:
          node-14: 192.168.200.14
          node-13: 192.168.200.13
        INSTANCE_BACKENDS: glusterfs   # optional configuration: local|glusterfs
        NODES: node-14,node-13
        ADD_NODE_ENABLED: False 
  
   neutron:
      NEUTRON_NETWORK_TYPE: vxlan  # optional configuration: vlan|gre|vxlan
      NETWORK_VLAN_RANGES: 101:130
      TUNNEL_ID_RANGES: 1:1000
      NETWORK_ENABLED: True
      PUBLIC_INTERFACE: eth1
      L3_ENABLED: True
      DATA_INTERFACE: eth0
      MANAGE_INTERFACE: eth0

   cinder:
      BACKENDS: glusterfs  # optional backends: glusterfs,local or cephonly support glusterfs now. 
      VOLUME_URL: node-14:/openstack -o backup-volfile-servers=node-13 # use ':' to seperate
