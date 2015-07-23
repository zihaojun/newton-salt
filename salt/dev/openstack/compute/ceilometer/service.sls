snmpd:
   service.running:
     - enable: True

openstack-ceilometer-compute:
   service.running:
     - enable: True
     - watch:
       - file: /etc/ceilometer/ceilometer.conf

/etc/ceilometer/ceilometer.conf:
    file.managed:
        - source: salt://dev/openstack/compute/ceilometer/templates/ceilometer.conf.compute.template
        - mode: 644
        - user: ceilometer
        - group: ceilometer
        - template: jinja
        - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_2') + ':5672,' + salt['pillar.get']('basic:corosync:NODE_1') + ':5672' }}
{% else %}
          VIP: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
          RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_1') + ':5672' }}
{% endif %}
          RABBIT_USER: {{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}
          RABBIT_PASS: {{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}
          AUTH_ADMIN_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_USER') }}
          AUTH_ADMIN_CEILOMETER_PASS: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_PASS') }}
          METERING_SECRET: {{ salt['pillar.get']('ceilometer:METERING_SECRET') }}
