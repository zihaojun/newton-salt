#!/bin/sh
mysql -uroot -popenstack -e "create database zabbix character set utf8;"
mysql -uroot -popenstack -e "grant all privileges on zabbix.* to 'zabbix'@'localhost' identified by 'zabbix';"
mysql -uroot -popenstack -e "flush privileges;"
cd /usr/share/doc/zabbix-server-mysql-3.0.10/
zcat create.sql.gz | mysql -uroot -popenstack zabbix
