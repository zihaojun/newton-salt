cinder:
    MYSQL_CINDER_USER: cinder
    MYSQL_CINDER_PASS: cinder
    MYSQL_CINDER_DBNAME: cinder
    AUTH_ADMIN_CINDER_USER: cinder
    AUTH_ADMIN_CINDER_PASS: cinder
    BACKENDS: glusterfs  # optional backends: glusterfs or ceph,only support glusterfs now. 
    VOLUME_URL: compute1:/openstack -o backup-volfile-servers=compute2:compute3 
