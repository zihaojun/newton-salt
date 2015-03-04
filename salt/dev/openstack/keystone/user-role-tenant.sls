/tmp/config.yaml:
   file.managed:
     - source: salt://dev/openstack/keystone/templates/config.yaml.template
     - template: jinja
     - defaults:
       ADMIN_TOKEN: {{ pillar['keystone'].get('ADMIN_TOKEN') }}
       IPADDR: {{ pillar['pacemaker'].get('VIP_HOSTNAME') }}
       NODE_1: {{ pillar['corosync'].get('NODE_1') }}
       ADMIN_USER: {{ pillar['keystone']['ADMIN_USER'] }}
       ADMIN_PASS: {{ pillar['keystone']['ADMIN_PASS'] }}
       AUTH_ADMIN_GLANCE_USER: {{ pillar['glance']['AUTH_ADMIN_GLANCE_USER'] }}
       AUTH_ADMIN_GLANCE_PASS: {{ pillar['glance']['AUTH_ADMIN_GLANCE_PASS'] }}
       AUTH_ADMIN_NOVA_USER: {{ pillar['nova']['AUTH_ADMIN_NOVA_USER'] }}
       AUTH_ADMIN_NOVA_PASS: {{ pillar['nova']['AUTH_ADMIN_NOVA_PASS'] }}
       AUTH_ADMIN_NEUTRON_USER: {{ pillar['neutron']['AUTH_ADMIN_NEUTRON_USER'] }}
       AUTH_ADMIN_NEUTRON_PASS: {{ pillar['neutron']['AUTH_ADMIN_NEUTRON_PASS'] }}
       AUTH_ADMIN_CINDER_USER: {{ pillar['cinder']['AUTH_ADMIN_CINDER_USER'] }}
       AUTH_ADMIN_CINDER_PASS: {{ pillar['cinder']['AUTH_ADMIN_CINDER_PASS'] }}
       AUTH_ADMIN_CEILOMETER_USER: {{ pillar['ceilometer']['AUTH_ADMIN_CEILOMETER_USER'] }}
       AUTH_ADMIN_CEILOMETER_PASS: {{ pillar['ceilometer']['AUTH_ADMIN_CEILOMETER_PASS'] }}


/tmp/keystone-init.py:
    file.managed:
      - source: salt://dev/openstack/keystone/files/keystone-init.py
      - mode: 755


create-user-role-tenant:
   cmd.run:
      - name: python /tmp/keystone-init.py /tmp/config.yaml
      - require:
        - file: /tmp/keystone-init.py
        - file: /tmp/config.yaml
