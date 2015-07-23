salt://dev/os_security/files/os_security_enhance.sh:
    cmd.script:
        - env:
          - BATCH: 'yes'
        - unless: {{ salt['cmd.run']('grep 1 /tmp/os_security_finished') }}
