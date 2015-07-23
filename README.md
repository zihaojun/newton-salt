# Getting Started
---
 According to different deployment scenarios，use different basic.sls configuration file.

## 1、Deploy Openstack HA

	node type:
			controller node： node-6,node-7
			compute-storage node： node-18,node-19
	
	[root@pxe openstack-deploy]# cat pillar/dev/openstack/basic.sls

	config_cinder_install: True

	config_heat_install: True

	config_ceilometer_install: True

	config_logstash_install: True

	config_compute_install: True

	config_storage_install: True

	config_ha_install: True        # enable openstack ha

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

   		influxdb:
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
        		CONTROLLER:
           			gluster-6: 172.16.100.6
           			gluster-7: 172.16.100.7  # if ip is 192.16.23.4，you should set hostname gluster-4
           			
        		STORAGE:
           			gluster-18: 172.16.100.18
           			gluster-19: 172.16.100.19

      		NODES: node-18,node-19
      		MANAGE_HOSTNAME_PREFIX: node- # if your manage ip hostname is compute-16，you should write compute-，if your manage ip hostname is compute16，you should write compute，this option is related to storage scale out.
      		STORAGE_NET: 172.16.100.0 
      		ENABLE_COMPUTE: True 
      		ADD_NODE_ENABLED: False
      		STORAGE_INTERFACE: eth2 # you can set the same as MANAGE_INTERFACE

   		glusterfs:
      		VOLUME_NODE: node-18
      		VOLUME_NAME: nova
      		BRICKS: /gfs/gluster
      		MOUNT_OPT: backup-volfile-servers=node-19

   		glance:
      		IMAGE_BACKENDS: glusterfs   # optional configuration: local|glusterfs
      		VOLUME_NAME: glance  # both node-6 and node-7 as glance glusterfs volume bricks backends 
      		BRICKS: /glance/gfs

   		nova:
      		CONTROLLER:
                        COMPUTE_ENABLED: False
        		HOSTS:
          			node-6: 192.168.200.6
          			node-7: 192.168.200.7
      		COMPUTE:
        		HOSTS:
          			node-18: 192.168.200.18
          			node-19: 192.168.200.19
        	INSTANCE_BACKENDS: glusterfs   # optional configuration: local|glusterfs
        	NODES: node-18,node-19
        	ADD_NODE_ENABLED: False

   		neutron:
      		NEUTRON_NETWORK_TYPE: vxlan  # optional configuration: vlan|gre|vxlan
      		NETWORK_VLAN_RANGES: 101:130
      		TUNNEL_ID_RANGES: 1:1000
      		NETWORK_ENABLED: True
      		PUBLIC_INTERFACE: eth1 # use the extra interface
      		L3_ENABLED: True
      		DATA_INTERFACE: eth0 # you can set the same as MANAGE_INTERFACE
      		MANAGE_INTERFACE: eth0

   		cinder:
      		BACKENDS: glusterfs  # optional backends: glusterfs,local or ceph.only support glusterfs now.
      		VOLUME_NAME: cinder # # you can set the same as nova,it means both cinder and nova can use the same glusterfs volume.
      		BRICKS: /cinder/gfs
      		VOLUME_URL: localhost:/cinder # use ':' to seperate

   		horizon:
      		ANIMBUS_ENABLED: True # if value is False，it will install the origin openstack horizon and ceilometer.
 
 
    		      		
## 2、Storage-compute node scale out with openstack ha
	node type:
			controller node: node-6,node-7
			compute-storage node：node-18,node-19
			To be added compute-storage node: node-20,node-21,node-22,node-23
	
	[root@pxe openstack-deploy]# cat pillar/dev/openstack/basic.sls

	config_cinder_install: True

	config_heat_install: True

	config_ceilometer_install: True

	config_logstash_install: True

	config_compute_install: True

	config_storage_install: True

	config_ha_install: True        # enable openstack ha

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

   		influxdb:
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
        		CONTROLLER:
           			gluster-6: 172.16.100.6
           			gluster-7: 172.16.100.7  # if ip is 192.16.23.4，you should set hostname gluster-4
           			
        		STORAGE:
           			gluster-18: 172.16.100.18
           			gluster-19: 172.16.100.19
           			gluster-20: 172.16.100.20  
           			gluster-21: 172.16.100.21
           			gluster-22: 172.16.100.22
           			gluster-23: 172.16.100.23

      		NODES: node-20,node-21,node-22,node-23
      		MANAGE_HOSTNAME_PREFIX: node- # if your manage ip hostname is compute-16，you should write compute-，if your manage ip hostname is compute16，you should write compute，this option is related to storage scale out.
      		STORAGE_NET: 172.16.100.0 
      		ENABLE_COMPUTE: True 
      		ADD_NODE_ENABLED: True  # enter storage scale out mode
      		STORAGE_INTERFACE: eth2 # you can set the same as MANAGE_INTERFACE

   		glusterfs:
      		VOLUME_NODE: node-18
      		VOLUME_NAME: nova
      		BRICKS: /gfs/gluster
      		MOUNT_OPT: backup-volfile-servers=node-19

   		glance:
      		IMAGE_BACKENDS: glusterfs   # optional configuration: local|glusterfs
      		VOLUME_NAME: glance  # both node-6 and node-7 as glance glusterfs volume bricks backends,now glance volume do not support scale out.
      		BRICKS: /glance/gfs

   		nova:
      		CONTROLLER:
                        COMPUTE_ENABLED: False
        		HOSTS:
          			node-6: 192.168.200.6
          			node-7: 192.168.200.7
      		COMPUTE:
        		HOSTS:
          			node-18: 192.168.200.18
          			node-19: 192.168.200.19
          			node-20: 192.168.200.20
          			node-21: 192.168.200.21
          			node-22: 192.168.200.22
          			node-23: 192.168.200.23 
        	INSTANCE_BACKENDS: glusterfs   # optional configuration: local|glusterfs
        	NODES: node-20,node-21,node-22,node-23 
        	ADD_NODE_ENABLED: True  # enter compute node scale out mode

   		neutron:
      		NEUTRON_NETWORK_TYPE: vxlan  # optional configuration: vlan|gre|vxlan
      		NETWORK_VLAN_RANGES: 101:130
      		TUNNEL_ID_RANGES: 1:1000
      		NETWORK_ENABLED: True
      		PUBLIC_INTERFACE: eth1 # use the extra interface
      		L3_ENABLED: True
      		DATA_INTERFACE: eth0 # you can set the same as MANAGE_INTERFACE
      		MANAGE_INTERFACE: eth0

   		cinder:
      		BACKENDS: glusterfs  # optional backends: glusterfs,local or ceph.only support glusterfs now.
      		VOLUME_NAME: cinder # # you can set the same as nova,it means both cinder and nova can use the same glusterfs volume.
      		BRICKS: /cinder/gfs
      		VOLUME_URL: localhost:/cinder # use ':' to seperate

   		horizon:
      		ANIMBUS_ENABLED: True

## 3、Deploy Openstack with single controller (have not been tested)

	node type:
			controller node： node-6
			compute-storage node： node-18,node-19
	
	[root@pxe openstack-deploy]# cat pillar/dev/openstack/basic.sls

	config_cinder_install: True

	config_heat_install: True

	config_ceilometer_install: True

	config_logstash_install: True

	config_compute_install: True

	config_storage_install: True

	config_ha_install: False        # disable openstack ha

	keystone.endpoint: 'http://node-6:35357/v2.0'

	basic:
   		rabbitmq:
      		DISC_NODE: node-6
      		RAM_NODE: 

   		mariadb:
      		MASTER: node-6
      		SLAVE: 

   		mongodb:
      		MASTER: node-6
      		SLAVE: 

   		influxdb:
      		MASTER: node-6
      		SLAVE: 

   		corosync:
      		HEARTBEAT_NET: 192.168.200.0
      		NODES: node-6
      		NODE_1: node-6
      		NODE_2: 
      
   		pacemaker:                        # if set config_ha_install is False，this section do not work
      		VIP: 192.168.200.20
      		VIP_HOSTNAME: controller
      		VIP_NETMASK: 24
      		VIP_NIC: eth0
      		VIP_PREFER_LOCATE: node-6

   		storage-common:
      		HOSTS:
        		CONTROLLER:      
           			gluster-6: 172.16.100.6  # if ip is 192.16.23.4，you should set hostname gluster-4
           			
        		STORAGE:
           			gluster-18: 172.16.100.18
           			gluster-19: 172.16.100.19

      		NODES: node-18,node-19
      		MANAGE_HOSTNAME_PREFIX: node- # if your manage ip hostname is compute-16，you should write compute-，if your manage ip hostname is compute16，you should write compute，this option is related to storage scale out.
      		STORAGE_NET: 172.16.100.0 
      		ENABLE_COMPUTE: True 
      		ADD_NODE_ENABLED: False
      		STORAGE_INTERFACE: eth2 # you can set the same as MANAGE_INTERFACE

   		glusterfs:
      		VOLUME_NODE: node-18
      		VOLUME_NAME: nova
      		BRICKS: /gfs/gluster
      		MOUNT_OPT: backup-volfile-servers=node-19

   		glance:
      		IMAGE_BACKENDS: local   # # if set config_ha_install is False，this option only support local,if you set IMAGE_BACKENDS is local,VOLUME_NAME and BRICKS do not work. 
      		VOLUME_NAME: glance  # both node-6 and node-7 as glance glusterfs volume bricks backends 
      		BRICKS: /glance/gfs

   		nova:
      		CONTROLLER:
                        COMPUTE_ENABLED: False
        		HOSTS:
          			node-6: 192.168.200.6     
      		COMPUTE:
        		HOSTS:
          			node-18: 192.168.200.18
          			node-19: 192.168.200.19
        	INSTANCE_BACKENDS: glusterfs   # optional configuration: local|glusterfs
        	NODES: node-18,node-19
        	ADD_NODE_ENABLED: False

   		neutron:
      		NEUTRON_NETWORK_TYPE: vxlan  # optional configuration: vlan|gre|vxlan
      		NETWORK_VLAN_RANGES: 101:130
      		TUNNEL_ID_RANGES: 1:1000
      		NETWORK_ENABLED: True
      		PUBLIC_INTERFACE: eth1 # use the extra interface
      		L3_ENABLED: True
      		DATA_INTERFACE: eth0 # you can set the same as MANAGE_INTERFACE
      		MANAGE_INTERFACE: eth0

   		cinder:
      		BACKENDS: glusterfs # optional backends: none,glusterfs,lvm or ceph.only support glusterfs、lvm now. 
      		VOLUME_NAME: cinder # you can set the same as nova,it means both cinder and nova can use the same glusterfs volume.
      		BRICKS: /cinder/gfs
      		VOLUME_URL: localhost:/cinder # use ':' to seperate

   		horizon:
      		ANIMBUS_ENABLED: True


## 4、How to deploy openstack 
salt-run state.orch dev.openstack-setup -l debug 
