#!/usr/bin/env python

from influxdb import InfluxDBClient

INFLUXDB_HOST = 'localhost'
INFLUXDB_PORT = 8086
INFLUXDB_USERNAME = 'root'
INFLUXDB_PASSWORD = 'root'
INFLUXDB_DATABASE = 'test2'

client = InfluxDBClient(
       INFLUXDB_HOST,
       INFLUXDB_PORT,
       INFLUXDB_USERNAME,
       INFLUXDB_PASSWORD,
       INFLUXDB_DATABASE)

client.create_database(INFLUXDB_DATABASE)

client.create_retention_policy("rollup_6m", '24w', 1,
              default=True, database=INFLUXDB_DATABASE)
