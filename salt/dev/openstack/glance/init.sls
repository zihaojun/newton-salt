include:
  - dev.openstack.glance.db
  - dev.openstack.glance.create-auth-user

glance:
  pkg.installed:
    - pkgs:
      - openstack-glance

{% for filename in ['glance-api.conf','glance-registry.conf'] %}
/etc/glance/{{ filename }}:
  file.managed:
    - source: salt://dev/openstack/glance/templates/{{ filename }}.template
    - template: jinja
    - default:
      GLANCE_DBPASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      GLANCE_USER_PASS: {{ salt['pillar.get']('public_password') }}
    - require:
      - pkg: glance
{% endfor %}

glance-service:
  cmd.script:
    - source: salt://dev/openstack/glance/templates/dbsync.sh
    - require:
      - file: /etc/glance/glance-api.conf
      - file: /etc/glance/glance-registry.conf
      - mysql_database: glance-database
