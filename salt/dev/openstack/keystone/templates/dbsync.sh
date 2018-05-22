#!/bin/bash
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password {{ ADMIN_PASS }} \
--bootstrap-admin-url http://{{ CONTROLLER }}:35357/v3/ \
--bootstrap-internal-url http://{{ CONTROLLER }}:35357/v3/ \
--bootstrap-public-url http://{{ CONTROLLER }}:5000/v3/ \
--bootstrap-region-id RegionOne
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
systemctl enable httpd.service
systemctl start httpd.service
