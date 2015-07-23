heat-init:
   pkg.installed:
       - pkgs:
          - openstack-heat-api
          - openstack-heat-engine
          - python-heatclient

salt://dev/openstack/heat/files/heat-db.sh:
    cmd.script:
        - template: jinja
        - require:
          - pkg: heat-init
        - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
{% else %}
          VIP: {{ grains['host'] }}
{% endif %}
          MYSQL_HEAT_USER: {{ salt['pillar.get']('heat:MYSQL_HEAT_USER') }}
          MYSQL_HEAT_PASS: {{ salt['pillar.get']('heat:MYSQL_HEAT_PASS') }}
          MYSQL_HEAT_DBNAME: {{ salt['pillar.get']('heat:MYSQL_HEAT_DBNAME') }}
        - env:
          - BATCH: 'yes'
