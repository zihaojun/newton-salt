#/bin/sh
systemctl enable rabbitmq-server
rabbitmqctl add_user openstack openstack
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
