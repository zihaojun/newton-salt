/etc/haproxy/haproxy.cfg:
   file.managed:
      - source: salt://dev/openstack/keystone/templates/haproxy.cfg.template 
      - mode: 644
      - template: jinja
      - defaults: 
        VIP_HOSTNAME: {{ salt['pillar.get']('pacemaker:VIP_HOSTNAME') }}
        NODE_1: {{ salt['pillar.get']('corosync:NODE_1') }}
        NODE_2: {{ salt['pillar.get']('corosync:NODE_2') }}
   service.running:
      - name: haproxy
      - watch:
        - file: /etc/haproxy/haproxy.cfg
