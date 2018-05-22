{% set CONTROLLER = salt['pillar.get']('nova:CONTROLLER') %}
{% set NEUTRON_USER_PASS = salt['pillar.get']('public_password') %}
{% set METADATA_SECRET = salt['pillar.get']('public_password') %}
include:
  - dev.openstack.neutron.db
  - dev.openstack.neutron.create-auth-user

neutron:
  pkg.installed:
    - pkgs:
      - openstack-neutron
      - openstack-neutron-ml2
      - openstack-neutron-linuxbridge
      - ebtables
      - ipset

{% for filename in ['neutron.conf','l3_agent.ini','dhcp_agent.ini','metadata_agent.ini'] %}
/etc/neutron/{{ filename }}:
  file.managed:
    - source: salt://dev/openstack/neutron/templates/{{ filename }}.template
    - template: jinja
    - default:
      NEUTRON_DBPASS: {{ salt['pillar.get']('public_password') }}
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      NEUTRON_USER_PASS: {{ salt['pillar.get']('public_password') }}
      NOVA_USER_PASS: {{ salt['pillar.get']('public_password') }}
      METADATA_SECRET: {{ salt['pillar.get']('public_password') }}
    - require:
      - pkg: neutron
{% endfor %}

{% for ml2file in ['ml2_conf.ini','linuxbridge_agent.ini'] %}
/etc/neutron/plugins/ml2/{{ ml2file }}:
  file.managed:
    - source: salt://dev/openstack/neutron/templates/{{ ml2file }}.template
    - template: jinja
    - default:
      PROVIDER_INTERFACE: {{ salt['pillar.get']('neutron:MANAGE_INTERFACE') }}
      CONTROLLER_IP: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
    - require:
      - pkg: neutron
{% endfor %}

neutron-nova:
  cmd.run:
    - name: sed -i '$a [neutron]\nurl = http://{{ CONTROLLER }}:9696\nauth_url = http://{{ CONTROLLER }}:35357\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nregion_name = RegionOne\nproject_name = service\nusername = neutron\npassword = {{ NEUTRON_USER_PASS }}\nservice_metadata_proxy = true\nmetadata_proxy_shared_secret = {{ METADATA_SECRET }}' /etc/nova/nova.conf
    - require:
      - cmd: auth-user-neutron
      - file: /etc/neutron/metadata_agent.ini
