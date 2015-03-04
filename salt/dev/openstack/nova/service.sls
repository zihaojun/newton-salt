openstack-nova:
  service.running:
    - names:
      - openstack-nova-api
      - openstack-nova-cert
      - openstack-nova-conductor
      - openstack-nova-consoleauth
      - openstack-nova-scheduler
{% if salt['pillar.get']('nova:VNC_ENABLED') %}
      - openstack-nova-novncproxy
{% else %}
      - openstack-nova-spicehtml5proxy
{% endif %}
{% if salt['pillar.get']('nova:COMPUTE_ENABLED') %}
      - openstack-nova-compute
{% endif %}
    - enable: True
