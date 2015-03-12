logstash-init:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODES') }}
       - tgt_type: list
       - sls:
         - dev.openstack.logstash

logstash-service:
   salt.state:
       - tgt: {{ salt['pillar.get']('basic:corosync:NODE_1') }}
       - tgt_type: list
       - sls:
         - dev.openstack.logstash.service
       - require:
         - salt: logstash-init 

