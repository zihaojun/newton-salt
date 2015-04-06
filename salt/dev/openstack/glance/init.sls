glance-init:
   pkg.installed:
      - pkgs:
        - openstack-glance
        - python-glanceclient
{% if salt['pillar.get']('basic:glance:IMAGE_BACKENDS','local') == 'glusterfs' %}
        - glusterfs
        - glusterfs-libs
        - glusterfs-fuse
        - glusterfs-api
{% endif %}

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
          VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
          MYSQL_GLANCE_USER: {{ salt['pillar.get']('glance:MYSQL_GLANCE_USER') }}
          MYSQL_GLANCE_PASS: {{ salt['pillar.get']('glance:MYSQL_GLANCE_PASS') }}
          MYSQL_GLANCE_DBNAME: {{ salt['pillar.get']('glance:MYSQL_GLANCE_DBNAME') }}
        - require:
          - pkg: glance-init
{% endfor %}

{% if salt['pillar.get']('basic:glance:IMAGE_BACKENDS','local') == 'glusterfs' %}
/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}:
   mount.mounted:
      - device: {{salt['pillar.get']('basic:glusterfs:VOLUME_NODE')}}:/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}
      - fstype: glusterfs
      - mkmnt: True
      - opts: {{ salt['pillar.get']('basic:glusterfs:MOUNT_OPT') }}

copy-glance-dir:
   cmd.run:
      - name: cp -r /var/lib/glance /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}/
      - unless: test -h /var/lib/glance
      - require:
        - mount: /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}

rmdir-glance-default:
   cmd.run:
      - name: rm -rf /var/lib/glance
      - onlyif: test -d /var/lib/glance
      - require:
        - cmd: copy-glance-dir

/{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}/glance:
   file.directory:
      - user: glance
      - group: glance
      - dir_mode: 755
      - file_mode: 644
      - recurse:
        - user
        - group
        - mode
      - require:
        - cmd: copy-glance-dir

/var/lib/glance:
   file.symlink:
      - target: /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}/glance 
      - require:
        - file: /{{salt['pillar.get']('basic:glusterfs:VOLUME_NAME')}}/glance
        - cmd: rmdir-glance-default

/etc/rc.d/rc.local:
   file.managed:
      - source: salt://dev/openstack/glance/templates/rc.local.template
      - mode: 755
      - template: jinja
      - defaults:
        VOLUME_URL: {{ salt['pillar.get']('basic:cinder:VOLUME_URL') }}
        VOLUME_NAME: {{ salt['pillar.get']('basic:glusterfs:VOLUME_NAME') }} 
{% endif %}
