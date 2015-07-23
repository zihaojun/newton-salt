openstack-ceilometer:
  service.running:
    - names:
      - snmpd
      - openstack-ceilometer-api
      - openstack-ceilometer-central
      - openstack-ceilometer-collector
      - openstack-ceilometer-notification
{% if salt['pillar.get']('basic:nova:CONTROLLER:COMPUTE_ENABLED',False) %}
      - openstack-ceilometer-compute
{% endif %}
    - enable: True
    - watch:
      - file: /etc/ceilometer/event_definitions.yaml
      - file: /etc/ceilometer/ceilometer.conf

/etc/ceilometer/event_definitions.yaml:
    file.managed:
        - source: salt://dev/openstack/ceilometer/files/event_definitions.yaml
        - mode: 644
        - user: ceilometer
        - group: ceilometer

/etc/ceilometer/ceilometer.conf:
    file.managed:
        - source: salt://dev/openstack/ceilometer/templates/ceilometer.conf.controller.template
        - mode: 644
        - user: ceilometer
        - group: ceilometer
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          RABBIT: {{ salt['pillar.get']('basic:corosync:NODE_2') + ':5672,' + salt['pillar.get']('basic:corosync:NODE_1') + ':5672' }}
          INFLUXDB_PORT: {{ '8087' }}
{% else %}
          VIP: {{ grains['host'] }}
          RABBIT: {{ grains['host'] + ':5672' }}
          INFLUXDB_PORT: {{ '8086' }}
{% endif %}
          RABBIT_USER: {{ salt['pillar.get']('rabbit:RABBIT_USER','guest') }}
          RABBIT_PASS: {{ salt['pillar.get']('rabbit:RABBIT_PASS','guest') }}
          MONGODB_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_USER') }}
          MONGODB_CEILOMETER_PASS: {{ salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_PASS') }}
          MONGODB_CEILOMETER_DBNAME: {{ salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_DBNAME') }}
          AUTH_ADMIN_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_USER') }}
          AUTH_ADMIN_CEILOMETER_PASS: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_PASS') }}
          METERING_SECRET: {{ salt['pillar.get']('ceilometer:METERING_SECRET') }}
          ANIMBUS_ENABLED: {{ salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED') }}
