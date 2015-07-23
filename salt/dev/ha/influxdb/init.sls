influxdb:
   pkg.installed:
      - pkgs:
        - influxdb
        - python-influxdb

{#
# It needs the local pip packages.
influxdb-client:
   pip.installed:
      - name: influxdb
#}
