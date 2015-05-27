#!/usr/bin/env python

from influxdb import InfluxDBClient

INFLUXDB_HOST = "{{ IPADDR }}" 
INFLUXDB_PORT = 8086
INFLUXDB_USERNAME = "{{ INFLUXDB_CEILOMETER_USER }}"
INFLUXDB_PASSWORD = "{{ INFLUXDB_CEILOMETER_PASS }}"
INFLUXDB_DATABASE = "{{ INFLUXDB_CEILOMETER_DBNAME }}"

client = InfluxDBClient(
       INFLUXDB_HOST,
       INFLUXDB_PORT,
       INFLUXDB_USERNAME,
       INFLUXDB_PASSWORD,
       INFLUXDB_DATABASE)

client.create_database(INFLUXDB_DATABASE)

client.create_retention_policy("rollup_6m", '24w', 1,
              default=True, database=INFLUXDB_DATABASE)
