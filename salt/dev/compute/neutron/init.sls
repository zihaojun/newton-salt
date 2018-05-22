{% set CONTROLLER = salt['pillar.get']('nova:CONTROLLER') %}
{% set NEUTRON_USER_PASS = salt['pillar.get']('public_password') %}

neutron-compute:
  pkg.installed:
    - pkgs:
      - openstack-neutron-linuxbridge
      - ebtables
      - ipset

/etc/neutron/neutron.conf:
  file.managed:
    - source: salt://dev/compute/neutron/templates/neutron.conf.template
    - template: jinja
    - default:
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      NEUTRON_USER_PASS: {{ salt['pillar.get']('public_password') }}
    - require:
      - pkg: neutron-compute

/etc/neutron/plugins/ml2/linuxbridge_agent.ini:
  file.managed:
    - source: salt://dev/compute/neutron/templates/linuxbridge_agent.ini.template
    - template: jinja
    - default:
      PROVIDER_INTERFACE: {{ salt['pillar.get']('neutron:MANAGE_INTERFACE') }}
    - require:
      - pkg: neutron-compute

neutron-nova:
  cmd.run:
    - name: sed -i '$a [neutron]\nurl = http://{{ CONTROLLER }}:9696\nauth_url = http://{{ CONTROLLER }}:35357\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nregion_name = RegionOne\nproject_name = service\nusername = neutron\npassword = {{ NEUTRON_USER_PASS }}' /etc/nova/nova.conf
    - require:
      - file: /etc/neutron/neutron.conf

neutron-compute-service:
  cmd.script:
    - source: salt://dev/compute/neutron/templates/neutron_compute_service.sh
    - require:
      - cmd: neutron-nova

