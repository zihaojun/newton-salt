config_cinder_install: True
config_heat_install: False 
config_ceilometer_install: True
config_logstash_install: True
config_compute_install: True 

keystone.endpoint: 'http://node-191:35357/v2.0'

basic:
   rabbitmq:
      DISC_NODE: node-191
      RAM_NODE: node-192
  
   mariadb:
      MASTER: node-191
      SLAVE: node-192
 
   mongodb:
      MASTER: node-191
      SLAVE: node-192

   corosync:
      HEARTBEAT_NET: 192.168.141.0
      NODES: node-191,node-192
      NODE_1: node-191
      NODE_2: node-192

   pacemaker:
      VIP: 192.168.141.60
      VIP_HOSTNAME: controller
      VIP_NETMASK: 24
      VIP_NIC: eth0
      VIP_PREFER_LOCATE: node-191

   storage-common:
      HOSTS: 
        gluster-1: 20.20.20.193
        gluster-2: 20.20.20.194
       
      NODES: node-193,node-194
      ENABLE_COMPUTE: True
      ADD_NODE_ENABLED: False
      STORAGE_INTERFACE: eth3

   glusterfs:
      VOLUME_NODE: node-193
      VOLUME_NAME: openstack
      BRICKS: /gfs/gluster
      MOUNT_OPT: backup-volfile-servers=node-194

   glance:
      IMAGE_BACKENDS: glusterfs   # optional configuration: local|glusterfs    

   nova:
      CONTROLLER:
        HOSTS:
          node-191: 192.168.141.191 
          node-192: 192.168.141.192
    
      COMPUTE:
        HOSTS:
          node-193: 192.168.141.193
          node-194: 192.168.141.194
        INSTANCE_BACKENDS: glusterfs   # optional configuration: local|glusterfs
        NODES: node-193,node-194
        ADD_NODE_ENABLED: False 
  
   neutron:
      NEUTRON_NETWORK_TYPE: vxlan  # optional configuration: vlan|gre|vxlan
      NETWORK_VLAN_RANGES: 101:130
      TUNNEL_ID_RANGES: 1:1000
      NETWORK_ENABLED: True
      PUBLIC_INTERFACE: eth1
      L3_ENABLED: True
      DATA_INTERFACE: eth2
      MANAGE_INTERFACE: eth0

   cinder:
      BACKENDS: glusterfs  # optional backends: glusterfs,local or cephonly support glusterfs now. 
      VOLUME_URL: node-193:/openstack -o backup-volfile-servers=node-194 # use ':' to seperate
