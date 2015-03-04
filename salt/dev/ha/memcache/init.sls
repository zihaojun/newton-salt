memcached:
   pkg:
     - installed
   service.running:
     - enable: True
     - require:
       - file: /etc/sysconfig/memcached
       - file: /usr/lib/systemd/system/memcached.service

/etc/sysconfig/memcached:
   file.managed:
     - source: salt://dev/ha/memcache/templates/memcached.template
     - mode: 644
     - template: jinja
     - defaults:
       HOSTNAME: {{ grains['host'] }} 
     - require:
       - pkg: memcached
       
/usr/lib/systemd/system/memcached.service:
   file.managed:
     - source: salt://dev/ha/memcache/files/memcached.service
     - mode: 644
     - require:
       - pkg: memcached
