#!/bin/bash
su -s /bin/sh -c "cinder-manage db sync" cinder
systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service openstack-cinder-volume.service target.service
systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service openstack-cinder-volume.service target.service
