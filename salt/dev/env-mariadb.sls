mariadb-init:
  salt.state:
    - tgt: {{ salt['pillar.get']('nova:CONTROLLER') }}
    - sls:
      - dev.env.mariadb
    - require:
      - salt: ntp-init
