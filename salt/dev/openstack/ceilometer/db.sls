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
