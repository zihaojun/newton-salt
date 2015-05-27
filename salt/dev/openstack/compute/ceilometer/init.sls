ceilometer-compute-init:
   pkg.installed:
      - pkgs:
         - net-snmp
{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED') %}
         - python-ceilometer: v3.1-1.el7.centos
         - openstack-ceilometer-common: v3.1-1.el7.centos
         - openstack-ceilometer-compute: v3.1-1.el7.centos
{% else %}
         - python-ceilometer: 2014.2.1-1.el7.centos 
         - openstack-ceilometer-common: 2014.2.1-1.el7.centos 
         - openstack-ceilometer-compute: 2014.2.1-1.el7.centos 
{% endif %}
         - python-pecan
         - python-ceilometerclient


/etc/snmp/snmpd.conf:
    file.managed:
        - source: salt://dev/openstack/compute/ceilometer/templates/snmpd.conf.template
        - mode: 600
        - user: root
        - group: root
        - require:
          - pkg: ceilometer-compute-init
        - template: jinja
        - defaults:
          COMMUNITY: {{ salt['pillar.get']('ceilometer:SNMP_COMMUNITY','') }}

/etc/ceilometer/ceilometer.conf:
    file.managed:
        - source: salt://dev/openstack/compute/ceilometer/templates/ceilometer.conf.compute.template
        - mode: 644
        - user: ceilometer
        - group: ceilometer
        - require:
          - pkg: ceilometer-compute-init
        - template: jinja
        - defaults:
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          AUTH_ADMIN_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_USER') }}
          AUTH_ADMIN_CEILOMETER_PASS: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_PASS') }}
          METERING_SECRET: {{ salt['pillar.get']('ceilometer:METERING_SECRET') }}
