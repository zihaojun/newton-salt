#!/bin/bash
cd /srv/openstack-deploy/salt/dev/monitor/glustermon/files
yum -y localinstall grafana-4.2.0-1.x86_64.rpm
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
