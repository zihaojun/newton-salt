ceilometer-compute-init:
   pkg.installed:
      - pkgs:
         - net-snmp
         - openstack-ceilometer-compute
         - python-ceilometerclient
         - python-pecan

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
          COMMUNITY: {{ pillar['config']['CEILOMETER']['SNMP_COMMUNITY'] }}

/etc/ceilometer/ceilometer.conf:
    file.managed:
        - source: salt://dev/openstack/compute/ceilometer/templates/ceilometer.conf.template
        - mode: 644
        - user: ceilometer
        - group: ceilometer
        - require:
          - pkg: ceilometer-compute-init
        - template: jinja
        - defaults:
