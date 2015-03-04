base:
  '*':
#     - openstack.config
     - ha.rabbitmq
     - ha.mariadb
     - ha.mongodb
     - ha.corosync
     - ha.pacemaker
     - ha.haproxy
     - openstack.keystone
     - openstack.glance
     - openstack.nova
     - openstack.neutron
     - openstack.cinder
     - openstack.ceilometer
     - storage.glusterfs
     - storage.ceph
     

