ntp-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
     - tgt_type: list
     - sls:
       - dev.ha.ntp
     - require:
       - salt: hosts-init

ntp-master-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
     - sls:
       - dev.ha.ntp.cluster.master
     - require:
       - salt: ntp-init

{% if salt['pillar.get']('config_ha_install',False) %}
ntp-slave-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:corosync:NODE_2') }}
     - sls:
       - dev.ha.ntp.cluster.slave
     - require:
       - salt: ntp-master-init
{% endif %}
