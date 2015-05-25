influxdb-init:
    salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.ha.influxdb
       - require:
         - salt: hosts-init

influxdb-cluster-init:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:influxdb:MASTER') }}
     - sls:
       - dev.ha.influxdb.cluster
     - require:
       - salt: influxdb-init

{#
join-influxdb-cluster:
  salt.state:
     - tgt: {{ salt['pillar.get']('basic:influxdb:SLAVE') }}
     - sls:
       - dev.ha.influxdb.cluster.add
     - require:
       - salt: influxdb-cluster-init 
#}
