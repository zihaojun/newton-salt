/root/.ssh:
   file.directory:
      - dir_mode: 700
      - file_mode: 644
      - user: root
      - group: root
      - recurse:
        - user
        - group
        - mode

/root/.ssh/id_rsa:
   file.managed:
      - source: salt://dev/ha/corosync/files/id_rsa
      - mode: 600
      - require:
        - file: /root/.ssh

/root/.ssh/config:
   file.managed:
      - source: salt://dev/ha/corosync/files/config
      - mode: 644
      - require:
        - file: /root/.ssh

/root/.ssh/authorized_keys:
   file.managed:
      - source: salt://dev/ha/corosync/files/authorized_keys
      - mode: 600
      - require:
        - file: /root/.ssh

pacemaker-crmsh-rely:
   pkg.installed:
      - pkgs:
        - cifs-utils
        - quota
        - psmisc
 
corosync-pacemaker:
   pkg.installed:
      - pkgs:
        - corosync 
        - pacemaker
        - crmsh 
      - require:
        - pkg: pacemaker-crmsh-rely

