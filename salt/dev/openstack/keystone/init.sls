keystone-init:
   pkg.installed:
      - pkgs:
        - openstack-keystone
        - python-keystoneclient
        - python-memcached
        - openstack-utils
        - httpd
        - mod_wsgi

/var/log/keystone/keystone.log:
   file.managed:
     - user: keystone
     - group: keystone
     - mode: 644
     - require:
       - pkg: keystone-init

{% if salt['pillar.get']('keystone:ENABLE_HTTPD_WSGI',True) %}
/var/www/cgi-bin/keystone:
    file.directory:
      - user: keystone
      - group: keystone
      - dir_mode: 755
      - file_mode: 644
      - recurse:
        - user
        - group
        - mode
      - require:
        - pkg: keystone-init

keystone-wsgi-execute:
   file.managed:
     - names:
       - /var/www/cgi-bin/keystone/admin
       - /var/www/cgi-bin/keystone/main
     - source: salt://dev/openstack/keystone/files/keystone.wsgi
     - user: keystone
     - group: keystone
     - mode: 755
     - require:
       - pkg: keystone-init
       - file: /var/www/cgi-bin/keystone
{% endif %}

salt://dev/openstack/keystone/files/keystone-db.sh:
    cmd.script:
        - template: jinja
        - require:
          - pkg: keystone-init
        - defaults:
{% if salt['pillar.get']('config_ha_install',False) %}
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
{% else %}
          VIP: {{ grains['host'] }}
{% endif %}
          MYSQL_KEYSTONE_USER: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_USER') }}
          MYSQL_KEYSTONE_PASS: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_PASS') }}
          MYSQL_KEYSTONE_DBNAME: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_DBNAME') }}
        - env:
          - BATCH: 'yes'

/root/keystonerc:
   file.managed:
     - source: salt://dev/openstack/keystone/templates/keystonerc.template
     - template: jinja
     - defaults:
       IPADDR: {{ grains['host'] }} 
       ADMIN_USER: {{ pillar['keystone']['ADMIN_USER'] }}
       ADMIN_PASS: {{ pillar['keystone']['ADMIN_PASS'] }}


{#
If keysotne choose to  use pki token,so you will need have shared storage
to store public key and private key in HA environment.Use uuid token to 
reduce complexity.
#} 
{% if salt['pillar.get']('keystone:TOKEN_TYPE','uuid') == 'pki' %}
keystone-pki-init:
    cmd.run:
      - name: keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
      - require:
        - pkg: keystone-init
    file.directory:
      - name: /etc/keystone/ssl
      - user: keystone
      - group: keystone
      - dir_mode: 755
      - file_mode: 644
      - recurse:
        - user
        - group
        - mode
      - require:
        - cmd: keystone-pki-init
{% endif %}
