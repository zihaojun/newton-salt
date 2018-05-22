/etc/profile:
  file.append:
    - text:
      - "export GOROOT=/home/go"
      - "export PATH=$GOROOT/bin:$PATH"
      - "export GOPATH=/home/go/pkg"

go.init:
  cmd.script:
    - source: salt://dev/monitor/glustermon/files/go.sh
    - require:
      - file: /etc/profile
