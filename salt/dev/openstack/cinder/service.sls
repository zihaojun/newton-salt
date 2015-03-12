openstack-cinder:
  service.running:
    - names:
      - openstack-cinder-api
      - openstack-cinder-scheduler
{% if salt['pillar.get']('basic:cinder:BACKENDS') != 'local' %}
      - openstack-cinder-volume
{% endif %}
    - enable: True


