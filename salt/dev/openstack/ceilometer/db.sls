{% set ceilometer_user = salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_USER') %}
{% set ceilometer_pass = salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_PASS') %}
{% set ceilometer_dbname = salt['pillar.get']('ceilometer:MONGODB_CEILOMETER_DBNAME') %}

salt://dev/openstack/ceilometer/files/ceilometer_mongodb_user.sh:
    cmd.script:
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
          MONGODB_CEILOMETER_DBNAME: {{ ceilometer_dbname }} 
          MONGODB_CEILOMETER_USER: {{ ceilometer_user }}
          MONGODB_CEILOMETER_PASS: "{{ ceilometer_pass }}"
        - env:
          - BATCH: 'yes'
        - unless: {{ salt['mongodb.user_exists'](ceilometer_user,'','',grains['host'],27017,ceilometer_dbname) }}

{% if salt['pillar.get']('basic:horizon:ANIMBUS_ENABLED',True) %}
salt://dev/openstack/ceilometer/files/influxdb_init.py:
    cmd.script:
        - template: jinja
        - defaults:
          IPADDR: {{ "localhost" }}
          INFLUXDB_CEILOMETER_USER: {{ salt['pillar.get']('ceilometer:INFLUXDB_CEILOMETER_USER') }}
          INFLUXDB_CEILOMETER_PASS: "{{ salt['pillar.get']('ceilometer:INFLUXDB_CEILOMETER_PASS') }}"
          INFLUXDB_CEILOMETER_DBNAME: {{ salt['pillar.get']('ceilometer:INFLUXDB_CEILOMETER_DBNAME') }}
        - env:
          - BATCH: 'yes'
{% endif %}
