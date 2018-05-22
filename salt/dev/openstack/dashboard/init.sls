dashboard:
  pkg.installed:
    - pkgs:
      - openstack-dashboard

/etc/openstack-dashboard/local_settings:
  file.managed:
    - source: salt://dev/openstack/dashboard/templates/local_settings.template
    - template: jinja
    - default:
      CONTROLLER: {{ salt['pillar.get']('nova:CONTROLLER') }}
      CONTROLLER_IP: {{ salt['pillar.get']('nova:CONTROLLER_IP') }}
    - require:
      - pkg: dashboard

dashboard-service:
  cmd.run:
    - name: systemctl restart httpd.service memcached.service
    - require:
      - file: /etc/openstack-dashboard/local_settings
