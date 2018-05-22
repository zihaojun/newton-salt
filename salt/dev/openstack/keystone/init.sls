include:
  - dev.openstack.keystone.db

keystone:
  pkg.installed:
    - pkgs:
      - openstack-keystone
      - httpd
      - mod_wsgi
      - python-openstackclient

{% for filename in ['keystone.conf','keystone-paste.ini'] %}
/etc/keystone/{{ filename }}:
  file.managed:
    - source: salt://dev/openstack/keystone/templates/{{ filename }}.template
    - template: jinja
    - default:
      KEYSTONE_DBPASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
    - require:
      - pkg: keystone
{% endfor %}

/etc/httpd/conf/httpd.conf:
  file.managed:
    - source: salt://dev/openstack/keystone/templates/httpd.conf.template
    - template: jinja
    - default:
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
    - require:
      - pkg: keystone

salt://dev/openstack/keystone/templates/dbsync.sh:
  cmd.script:
    - template: jinja
    - default:
      ADMIN_PASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
    - require:
      - mysql_database: keystone-database
      - file: /etc/keystone/keystone.conf
      - file: /etc/httpd/conf/httpd.conf

/root/adminrc:
  file.managed:
    - source: salt://dev/openstack/keystone/templates/adminrc
    - template: jinja
    - default:
      ADMIN_PASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}

create-service-project:
  cmd.run:
    - name: source /root/adminrc && openstack project create --domain default --description "Service Project" service && openstack role create user
    - require:
      - file: /root/adminrc
      - cmd: salt://dev/openstack/keystone/templates/dbsync.sh
