keystone.endpoint: 'http://node-34:35357/v2.0'

basic:
   rabbitmq:
      DISC_NODE: node-34
      RAM_NODE: node-35
  
   mariadb:
      MASTER: node-34
      SLAVE: node-35
 
   mongodb:
      MASTER: node-34
      SLAVE: node-35

   corosync:
      HEARTBEAT_NET: 172.20.10.0
      NODES: node-34,node-35
      NODE_1: node-34
      NODE_2: node-35

   pacemaker:
      VIP: 172.20.11.60
      VIP_HOSTNAME: controller
      VIP_NETMASK: 24
      VIP_NIC: eth0
      VIP_PREFER_LOCATE: node-34

   storage-common:
      HOSTS: 
        gluster30: 10.0.0.30
        gluster31: 10.0.0.31
        gluster32: 10.0.0.32
        gluster33: 10.0.0.33
        gluster34: 10.0.0.34
        gluster35: 10.0.0.35
        gluster36: 10.0.0.36
        gluster37: 10.0.0.37
       
      NODES: compute-1,compute-2
      ENABLE_COMPUTE: False 
      ADD_NODE_ENABLED: True
      STORAGE_INTERFACE: eth0

   glusterfs:
      VOLUME_NODE: gluster36
      VOLUME_NAME: openstack
      BRICKS: /mnt/gluster
      MOUNT_OPT: backup-volfile-servers=gluster-2

   glance:
      IMAGE_BACKENDS: local   # optional configuration: local|glusterfs    

   nova:
      CONTROLLER:
        HOSTS:
          node-34: 172.20.11.34
          node-35: 172.20.11.35
    
      COMPUTE:
        HOSTS:
          node-30: 172.20.11.30
          node-31: 172.20.11.31
          node-32: 172.20.11.32
          node-33: 172.20.11.33
          node-36: 172.20.11.36
          node-37: 172.20.11.37
        INSTANCE_BACKENDS: local   # optional configuration: local|glusterfs
        NODES: node-30,node-31,node-32,node-33
        ADD_NODE_ENABLED: True 
  
   neutron:
      NEUTRON_NETWORK_TYPE: vxlan  # optional configuration: vlan|gre|vxlan
      NETWORK_VLAN_RANGES: 101:130
      TUNNEL_ID_RANGES: 1:1000
      NETWORK_ENABLED: True
      PUBLIC_INTERFACE: eth1
      L3_ENABLED: False
      DATA_INTERFACE: eth0
      MANAGE_INTERFACE: eth0

   cinder:
      BACKENDS: local  # optional backends: glusterfs,local or cephonly support glusterfs now. 
      VOLUME_URL: gluster-1:/openstack -o backup-volfile-servers=gluster-2

