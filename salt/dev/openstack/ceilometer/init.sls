ceilometer-init:
   pkg.installed:
       - pkgs:
          - net-snmp
{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED') %}
          - python-ceilometer: v3.1-1.el7.centos
          - openstack-ceilometer-common: v3.1-1.el7.centos
          - openstack-ceilometer-api: v3.1-1.el7.centos 
          - openstack-ceilometer-collector: v3.1-1.el7.centos
          - openstack-ceilometer-notification: v3.1-1.el7.centos
          - openstack-ceilometer-central: v3.1-1.el7.centos
{% else %}
          - python-ceilometer: 2014.2.1-1.el7.centos
          - openstack-ceilometer-common: 2014.2.1-1.el7.centos
          - openstack-ceilometer-api: 2014.2.1-1.el7.centos
          - openstack-ceilometer-collector: 2014.2.1-1.el7.centos
          - openstack-ceilometer-notification: 2014.2.1-1.el7.centos
          - openstack-ceilometer-central: 2014.2.1-1.el7.centos
{% endif %}
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

/etc/ceilometer/event_definitions.yaml:
    file.managed:
        - source: salt://dev/openstack/ceilometer/files/event_definitions.yaml
        - mode: 644
        - user: ceilometer
        - group: ceilometer
        - require:
          - pkg: ceilometer-init 

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
          ANIMBUS_ENABLED: {{ salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED') }}
