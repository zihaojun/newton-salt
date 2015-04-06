include:
  - dev.openstack.logstash.common 

logstash-compute-init:
   pkg.installed:
      - pkgs:
        - logstash

extend:
   /etc/logstash/conf.d/collect:
     file.recurse:
         - require:
           - pkg: logstash-compute-init

   /etc/logstash/conf.d/collect/output-rabbitmq.conf:
     file.managed:
         - require:
           - pkg: logstash-compute-init
           - file: /etc/logstash/conf.d/collect

   /opt/logstash/patterns/openstack:
     file.managed:
         - require:
           - pkg: logstash-compute-init
