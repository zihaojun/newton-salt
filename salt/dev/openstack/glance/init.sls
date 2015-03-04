glance-init:
   pkg.installed:
      - pkgs:
        - openstack-glance
        - python-glanceclient

{% for srv in ['api','registry'] %}
/var/log/glance/{{srv}}.log:
     file.managed:
        - user: glance
        - group: glance
        - mode: 644
        - require:
          - pkg: glance-init
{% endfor %}

{% for srv in ['api','registry'] %}
/etc/glance/glance-{{ srv }}.conf:
    file.managed:
        - source: salt://dev/openstack/glance/templates/glance-{{ srv }}.conf.template
        - mode: 644
        - user: glance
        - group: glance
        - template: jinja
        - defaults:
          AUTH_ADMIN_GLANCE_USER: {{ salt['pillar.get']('glance:AUTH_ADMIN_GLANCE_USER') }}
          AUTH_ADMIN_GLANCE_PASS: {{ salt['pillar.get']('glance:AUTH_ADMIN_GLANCE_PASS') }}
          IPADDR: {{ grains['host'] }}
          VIP: {{ salt['pillar.get']('pacemaker:VIP_HOSTNAME') }}
          MYSQL_GLANCE_USER: {{ salt['pillar.get']('glance:MYSQL_GLANCE_USER') }}
          MYSQL_GLANCE_PASS: {{ salt['pillar.get']('glance:MYSQL_GLANCE_PASS') }}
          MYSQL_GLANCE_DBNAME: {{ salt['pillar.get']('glance:MYSQL_GLANCE_DBNAME') }}
        - require:
          - pkg: glance-init
{% endfor %}
