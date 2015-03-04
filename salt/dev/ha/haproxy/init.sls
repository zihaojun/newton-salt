haproxy-keepalived:
   pkg.installed:
      - pkgs:
        - haproxy 
        - keepalived

/etc/haproxy/haproxy.cfg:
   file.managed:
      - source: salt://dev/ha/haproxy/templates/haproxy.cfg.template
      - mode: 644
      - template: jinja
      - defaults:
        VIP_HOSTNAME: {{ salt['pillar.get']('pacemaker:VIP_HOSTNAME') }}
        NODE_1: {{ salt['pillar.get']('corosync:NODE_1') }}
        NODE_2: {{ salt['pillar.get']('corosync:NODE_2') }}
      - require:
        - pkg: haproxy-keepalived


