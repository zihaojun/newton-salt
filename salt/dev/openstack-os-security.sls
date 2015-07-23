os-security-init:
   salt.state:
       - tgt: '*'
       - sls:
         - dev.os_security
       - require:
{% if not salt['pillar.get']('basic:nova:COMPUTE:ADD_NODE_ENABLED',True) %}
         - salt: horizon-init
{% endif %}
{% if salt['pillar.get']('config_compute_install',False) %}
         - salt: nova-compute-service
         - salt: neutron-compute-service
{% if salt['pillar.get']('config_ceilometer_install',False) %}
         - salt: ceilometer-compute-service
{% endif %}
{% if salt['pillar.get']('config_logstash_install',False) %}
         - salt: logstash-compute-service
{% endif %}
{% endif %}
 
