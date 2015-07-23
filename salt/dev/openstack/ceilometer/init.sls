{% set ceilometer_version = salt['cmd.run']("yum list | awk '/ceilometer-api/ {for(i=1;i<=NF;i++) if($i ~ /(v3.1)/)  print $i }'") %}

ceilometer-init:
   pkg.installed:
       - pkgs:
          - net-snmp
{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED') %}
          - python-ceilometer: {{ ceilometer_version }}
          - openstack-ceilometer-common: {{ ceilometer_version }}
          - openstack-ceilometer-api: {{ ceilometer_version }} 
          - openstack-ceilometer-collector: {{ ceilometer_version }}
          - openstack-ceilometer-notification: {{ ceilometer_version }}
          - openstack-ceilometer-central: {{ ceilometer_version }}
          - openstack-ceilometer-compute: {{ ceilometer_version }}
{% else %}
          - python-ceilometer: 2014.2.1-1.el7.centos
          - openstack-ceilometer-common: 2014.2.1-1.el7.centos
          - openstack-ceilometer-api: 2014.2.1-1.el7.centos
          - openstack-ceilometer-collector: 2014.2.1-1.el7.centos
          - openstack-ceilometer-notification: 2014.2.1-1.el7.centos
          - openstack-ceilometer-central: 2014.2.1-1.el7.centos
          - openstack-ceilometer-compute: 2014.2.1-1.el7.centos
{% endif %}
          - python-pecan
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

