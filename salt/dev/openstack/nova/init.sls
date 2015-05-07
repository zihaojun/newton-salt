include:
  - dev.openstack.nova.common

nova-init:
   pkg.installed:
      - pkgs:
           - openstack-nova-api
           - openstack-nova-cert
           - openstack-nova-conductor
           - openstack-nova-console
           - openstack-nova-novncproxy
           - openstack-nova-scheduler
           - openstack-nova-compute
           - python-novaclient
           - spice-server
           - openstack-nova-spicehtml5proxy 
           - sysfsutils

extend:
   ch_nova_shell:
     cmd.run:
         - require:
           - pkg: nova-init


/etc/nova/nova.conf:
   file.managed:
        - source: salt://dev/openstack/nova/templates/nova.conf.controller.template
        - mode: 644
        - user: nova
        - group: nova
        - require:
          - pkg: nova-init
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          VNC_ENABLED: {{ salt['pillar.get']('nova:VNC_ENABLED') }}
          COMPUTE_ENABLED: {{ salt['pillar.get']('nova:COMPUTE_ENABLED') }}
          MYSQL_NOVA_USER: {{ salt['pillar.get']('nova:MYSQL_NOVA_USER') }}
          MYSQL_NOVA_PASS: {{ salt['pillar.get']('nova:MYSQL_NOVA_PASS') }}
          MYSQL_NOVA_DBNAME: {{ salt['pillar.get']('nova:MYSQL_NOVA_DBNAME') }}
          AUTH_ADMIN_NOVA_USER: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_USER') }}
          AUTH_ADMIN_NOVA_PASS: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_PASS') }}
          METADATA_PROXY_SECRET: {{ salt['pillar.get']('nova:METADATA_PROXY_SECRET') }} 
          AUTH_ADMIN_NEUTRON_USER: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_USER') }}
          AUTH_ADMIN_NEUTRON_PASS: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_PASS') }}
