logstash-compute-init:
   pkg.installed:
      - pkgs:
        - logstash
        - logstash-contrib

/etc/logstash/conf.d/shipper.conf:
   file.managed:
      - source: salt://dev/openstack/compute/logstash/templates/shipper.conf.template
      - mode: 644
      - template: jinja
      - defaults:
        VIP: {{ salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') }}
      - require:
        - pkg: logstash-compute-init
