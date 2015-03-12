os-util-pkg:
   pkg.installed:
      - pkgs:
        - net-tools

/etc/hosts:
   file.managed:
      - source: salt://dev/openstack/hosts/templates/hosts.template
      - template: jinja
      - defaults:
        COMPUTE_HOSTS: {{ salt['pillar.get']('basic:nova:COMPUTE:HOSTS',False) }}
        CONTROLLER_HOSTS: {{ salt['pillar.get']('basic:nova:CONTROLLER:HOSTS',False) }}
        STORAGE_HOSTS: {{ salt['pillar.get']('basic:storage-common:HOSTS',False) }}
        ENABLE_COMPUTE: {{ salt['pillar.get']('basic:storage-common:ENABLE_COMPUTE',False) }}

add-vip-hosts:
   host.present:
       - name: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
       - ip: {{ salt['pillar.get']('basic:pacemaker:VIP') }}
       - require: 
         - file: /etc/hosts
