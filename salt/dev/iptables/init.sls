iptables:
  pkg.installed:
    - name: iptables-services
  file.managed:
    - name: /etc/sysconfig/iptables
    - source: salt://dev/iptables/files/iptables
    - require:
      - pkg: iptables
  service.running:
    - enable: True
    - watch:
      - pkg: iptables
      - file: iptables
