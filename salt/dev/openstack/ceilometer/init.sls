ceilometer-init:
   pkg.installed:
       - pkgs:
          - net-snmp
          - openstack-ceilometer-api
          - openstack-ceilometer-collector
          - openstack-ceilometer-notification
          - openstack-ceilometer-central
          - python-ceilometerclient

/etc/snmp/snmpd.conf:
    file.managed:
        - source: salt://dev/openstack/ceilometer/templates/snmpd.conf.template
        - mode: 600
        - user: root
        - group: root
        - require:
          - pkg: ceilometer-init
        - template: jinja
        - defaults:
          COMMUNITY: {{ salt['pillar.get']('ceilometer:SNMP_COMMUNITY') }}

/etc/ceilometer/ceilometer.conf:
    file.managed:
        - source: salt://dev/openstack/ceilometer/templates/ceilometer.conf.controller.template
        - mode: 644
        - user: ceilometer
        - group: ceilometer
        - require:
          - pkg: ceilometer-init
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          MONGODB_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_USER') }}
          MONGODB_CEILOMETER_PASS: {{ salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_PASS') }}
          MONGODB_CEILOMETER_DBNAME: {{ salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_DBNAME') }}
          AUTH_ADMIN_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_USER') }}
          AUTH_ADMIN_CEILOMETER_PASS: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_PASS') }}
          METERING_SECRET: {{ salt['pillar.get']('ceilometer:METERING_SECRET') }}

