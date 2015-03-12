{% set vip_hostname = salt['pillar.get']('basic:pacemaker:VIP_HOSTNAME') %}
keystone-tenants:
  keystone.tenant_present:
    - names:
      - admin
      - service

keystone-roles:
  keystone.role_present:
    - names:
      - admin
      - Member
      - workflow
      - heat_stack_user
      - heat_stack_owner

{{ salt['pillar.get']('keystone:ADMIN_USER','admin') }}:
  keystone.user_present:
    - password: {{ salt['pillar.get']('keystone:ADMIN_PASS','admin') }}
    - email: admin@domain.com
    - roles:
      - admin:   
        - admin  
      - service:
        - admin
        - Member
    - require:
      - keystone: keystone-tenants
      - keystone: keystone-roles


{% set user_list = ['glance','nova','neutron','cinder','ceilometer','heat'] %} 
{% for user in user_list %}
{{user}}:
  keystone.user_present:
{% if user == 'glance' %}
    - name: {{ salt['pillar.get']('glance:AUTH_ADMIN_GLANCE_USER') }}
    - password: {{ salt['pillar.get']('glance:AUTH_ADMIN_GLANCE_PASS') }}
{% elif user == 'nova' %}
    - name: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_USER') }}
    - password: {{ salt['pillar.get']('nova:AUTH_ADMIN_NOVA_PASS') }}   
{% elif user == 'neutron' %}
    - name: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_USER') }}
    - password: {{ salt['pillar.get']('neutron:AUTH_ADMIN_NEUTRON_PASS') }} 
{% elif user == 'cinder' %}
    - name: {{ salt['pillar.get']('cinder:AUTH_ADMIN_CINDER_USER') }}
    - password: {{ salt['pillar.get']('cinder:AUTH_ADMIN_CINDER_PASS') }} 
{% elif user == 'ceilometer' %}
    - name: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_USER') }}
    - password: {{ salt['pillar.get']('ceilometer:AUTH_ADMIN_CEILOMETER_PASS') }} 
{% elif user == 'heat' %}
    - name: {{ salt['pillar.get']('heat:AUTH_ADMIN_HEAT_USER') }}
    - password: {{ salt['pillar.get']('heat:AUTH_ADMIN_HEAT_PASS') }}
{% endif %}
    - email: {{user}}@domain.com
    - tenant: service
    - roles:
      - service:
        - admin
    - require:
      - keystone: keystone-tenants
      - keystone: keystone-roles
{% endfor %}


{% set service_list = ['keystone','glance','nova','neutron','cinder','cinderv2','ceilometer','heat'] %}
{% for srv in service_list %}
{{srv}}-srv:
  keystone.service_present:
    - name: {{srv}}
{% if srv == 'keystone' %}
    - service_type: identity
    - description: Keystone Identity Service
{% elif srv == 'glance' %}
    - service_type: image
    - description: Glance Image Service 
{% elif srv == 'nova' %}
    - service_type: compute
    - description: Nova Compute Service 
{% elif srv == 'neutron' %}
    - service_type: network 
    - description: Neutron Network Service 
{% elif srv == 'cinder' %}
    - service_type: volume
    - description: cinder Volume Service
{% elif srv == 'cinderv2' %}
    - service_type: volumev2
    - description: cinder Volume Service
{% elif srv == 'ceilometer' %}
    - service_type: metering
    - description: Telemetry Service 
{% elif srv == 'heat' %}
    - service_type: orchestration
    - description: Orchestration Service
{% endif %}
{% endfor %}

{% for srv in service_list %}
{{srv}}-endpoint:
  keystone.endpoint_present:
    - name: {{srv}}
{% if srv == 'keystone' %}
    - publicurl:   http://{{ vip_hostname }}:5000/v2.0
    - internalurl: http://{{ vip_hostname }}:5000/v2.0
    - adminurl:    http://{{ vip_hostname }}:35357/v2.0
{% elif srv == 'glance' %}
    - publicurl:   http://{{ vip_hostname }}:9292
    - internalurl: http://{{ vip_hostname }}:9292
    - adminurl:    http://{{ vip_hostname }}:9292
{% elif srv == 'nova' %}
    - publicurl:   http://{{ vip_hostname }}:8774/v2/%(tenant_id)s
    - internalurl: http://{{ vip_hostname }}:8774/v2/%(tenant_id)s
    - adminurl:    http://{{ vip_hostname }}:8774/v2/%(tenant_id)s
{% elif srv == 'neutron' %}
    - publicurl:   http://{{ vip_hostname }}:9696
    - internalurl: http://{{ vip_hostname }}:9696
    - adminurl:    http://{{ vip_hostname }}:9696
{% elif srv == 'cinder' %}
    - publicurl:    http://{{ vip_hostname }}:8776/v1/%(tenant_id)s
    - internalurl:  http://{{ vip_hostname }}:8776/v1/%(tenant_id)s
    - adminurl:     http://{{ vip_hostname }}:8776/v1/%(tenant_id)s
{% elif srv == 'cinderv2' %}
    - publicurl:    http://{{ vip_hostname }}:8776/v2/%(tenant_id)s
    - internalurl:  http://{{ vip_hostname }}:8776/v2/%(tenant_id)s
    - adminurl:     http://{{ vip_hostname }}:8776/v2/%(tenant_id)s
{% elif srv == 'ceilometer' %}
    - publicurl:    http://{{ vip_hostname }}:8777
    - internalurl:  http://{{ vip_hostname }}:8777
    - adminurl:     http://{{ vip_hostname }}:8777
{% elif srv == 'heat' %}
    - publicurl:    http://{{ vip_hostname }}:8004/v1/%\(tenant_id\)s  
    - internalurl:  http://{{ vip_hostname }}:8004/v1/%\(tenant_id\)s
    - adminurl:     http://{{ vip_hostname }}:8004/v1/%\(tenant_id\)s
{% endif %}
    - region: regionOne
    - require:
      - keystone: {{srv}}-srv
{% endfor %}
