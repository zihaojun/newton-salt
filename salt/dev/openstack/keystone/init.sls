keystone-init:
   pkg.installed:
      - pkgs:
        - openstack-keystone
        - python-keystoneclient
        - python-memcached

/var/log/keystone/keystone.log:
   file.managed:
     - user: keystone
     - group: keystone
     - mode: 644
     - require:
       - pkg: keystone-init

/etc/keystone/keystone.conf:
   file.managed:
      - source: salt://dev/openstack/keystone/templates/keystone.conf.template
      - mode: 640
      - user: keystone
      - group: keystone
      - template: jinja
        ADMIN_TOKEN: {{ salt['pillar.get']('keystone:ADMIN_TOKEN') }}
        IPADDR: {{ grains['host'] }}
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
        MYSQL_KEYSTONE_USER: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_USER') }}
        MYSQL_KEYSTONE_PASS: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_PASS') }}
        MYSQL_KEYSTONE_DBNAME: {{ salt['pillar.get']('keystone:MYSQL_KEYSTONE_DBNAME') }}
      - require:
        - pkg: keystone-init

/root/keystonerc:
   file.managed:
     - source: salt://dev/openstack/keystone/templates/keystonerc.template
     - template: jinja
     - defaults:
       IPADDR: {{ grains['host'] }} 
       ADMIN_USER: {{ pillar['keystone']['ADMIN_USER'] }}
       ADMIN_PASS: {{ pillar['keystone']['ADMIN_PASS'] }}


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
