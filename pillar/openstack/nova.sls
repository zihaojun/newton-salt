nova:
    MYSQL_NOVA_USER: nova
    MYSQL_NOVA_PASS: nova
    MYSQL_NOVA_DBNAME: nova
    AUTH_ADMIN_NOVA_USER: nova
    AUTH_ADMIN_NOVA_PASS: nova
    METADATA_PROXY_SECRET: meta_pass
    VNC_ENABLED: True
    COMPUTE_ENABLED: False
    CONTROLLER:
        HOSTS:
          minion-1: 172.16.120.4
          minion-2: 172.16.120.5
    COMPUTE:
        HOSTS:
          minion-1: 172.16.120.4
          minion-2: 172.16.120.5
        NODES: minion-1,minion-2
