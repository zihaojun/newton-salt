salt://dev/openstack/ceilometer/files/ceilometer_mongodb_user.sh:
    cmd.script:
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
          MONGODB_CEILOMETER_DBNAME: {{ salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_DBNAME') }}
          MONGODB_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_USER') }}
          MONGODB_CEILOMETER_PASS: {{ salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_PASS') }}
        - env:
          - BATCH: 'yes'

{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED',True) %}
salt://dev/openstack/ceilometer/files/influxdb_init.py:
    cmd.script:
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
          INFLUXDB_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:INFLUXDB_CEILOMETER_USER') }}
          INFLUXDB_CEILOMETER_PASS: {{ salt['pillar.get']('ceilometer:INFLUXDB_CEILOMETER_PASS') }}
          INFLUXDB_CEILOMETER_DBNAME: {{ salt['pillar.get']('ceilometer:INFLUXDB_CEILOMETER_DBNAME') }}
        - env:
          - BATCH: 'yes'
{% endif %}
