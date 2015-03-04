salt://dev/ha/corosync/files/add_resource.sh:    
   cmd.script:
        - template: jinja
        - defaults:
          ENABLE_KEEPALIVED: {{ salt['pillar.get']('haproxy:ENABLE_KEEPALIVED') }}
          VIP: {{ salt['pillar.get']('pacemaker:VIP') }}
          VIP_NIC: {{ salt['pillar.get']('pacemaker:VIP_NIC') }}
          VIP_NETMASK: {{ salt['pillar.get']('pacemaker:VIP_NETMASK') }}
          VIP_PREFER_LOCATE: {{ salt['pillar.get']('pacemaker:VIP_PREFER_LOCATE') }}
        - env:
          - BATCH: 'yes'

