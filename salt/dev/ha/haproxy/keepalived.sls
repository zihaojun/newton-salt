/etc/sysctl.d/99-salt.conf:
    file.touch

net.ipv4.ip_nonlocal_bind:
    sysctl.present:
       - value: 1
       - config: /etc/sysctl.conf
       - require:
         - file: /etc/sysctl.d/99-salt.conf

/etc/keepalived/keepalived.conf:
    file.managed:
      - source: salt://dev/ha/haproxy/templates/keepalived.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('pacemaker:VIP') }}
        MANAGE_INTERFACE: {{ salt['pillar.get']('neutron:MANAGE_INTERFACE') }} 

keepalived:
    service.running:
      - enable: True
      - watch:
        - file: /etc/keepalived/keepalived.conf


