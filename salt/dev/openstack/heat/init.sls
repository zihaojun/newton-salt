heat-init:
   pkg.installed:
       - pkgs:
          - openstack-heat-api
          - openstack-heat-engine
          - python-heatclient

/etc/heat/heat.conf:
   file.managed:
        - source: salt://dev/openstack/heat/templates/heat.conf.template
        - mode: 644
        - user: heat
        - group: heat
        - template: jinja
        - defaults:
          IPADDR: {{ grains['host'] }}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          MYSQL_HEAT_USER: {{ salt['pillar.get']('heat:MYSQL_HEAT_USER') }}
          MYSQL_HEAT_PASS: {{ salt['pillar.get']('heat:MYSQL_HEAT_PASS') }}
          MYSQL_HEAT_DBNAME: {{ salt['pillar.get']('heat:MYSQL_HEAT_DBNAME') }}
          AUTH_ADMIN_HEAT_USER: {{ salt['pillar.get']('heat:AUTH_ADMIN_HEAT_USER') }}
          AUTH_ADMIN_HEAT_PASS: {{ salt['pillar.get']('heat:AUTH_ADMIN_HEAT_PASS') }}
        - require:
          - pkg: heat-init

