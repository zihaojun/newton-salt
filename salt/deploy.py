#!/usr/bin/env python
#coding=utf-8

import urllib2,urllib,json,re
import yaml
import sys,time

class saltAPI:
     def __init__(self):
         self.__url = 'https://192.168.88.41:8888'
         self.__user = 'saltapi'
         self.__password = 'yao'
         self.__token_id = self.salt_login()


     def salt_login(self):
         params = {'eauth': 'pam',
                   'username': self.__user,
                   'password': self.__password
                  }
         encode = urllib.urlencode(params)
         obj = urllib.unquote(encode)
         headers = {'X-Auth-Token': ''}
         url = self.__url + '/login'
         req = urllib2.Request(url,obj,headers)
         opener = urllib2.urlopen(req)
         content = json.loads(opener.read())
         try:
             token = content['return'][0]['token']
             return token
         except KeyError:
             raise KeyError
   
     def postRequest(self,obj,prefix='/'):
         url = self.__url + prefix
         headers = {'X-Auth-Token': self.__token_id}
         req = urllib2.Request(url,obj,headers)
         opener = urllib2.urlopen(req)
         content = json.loads(opener.read())
         return content['return']
 
     def parseConfig(self,filename):
         config = yaml.load(file(filename,'r'))
         return config

     def getHostlist(self):
         config = self.parseConfig('/srv/pillar/openstack/config.sls')
         domain_name = config['config']['DEPLOY'].get('DOMAIN_NAME')
         dhcp_host_list = config['config']['DEPLOY'].get('DHCP_HOST')
         host_list = [] 
         if dhcp_host_list:
            for dhcp_host in dhcp_host_list:
                host_list.append(dhcp_host.split(',')[2]+'.'+domain_name) 
         return host_list

     def saltCmd(self,params):
         obj = urllib.urlencode(params)
#         obj, number = re.subn("arg\d",'arg',obj)
         res = self.postRequest(obj)
         return res


def main():
    saltapi = saltAPI()
    ping_params = {
              'client': 'local',
              'fun': 'test.ping',
              'tgt': '*'
                  }

    deploy_params = {
               'client': 'local',
               'fun': 'state.highstate',
               'tgt': '*'
                  }

    while True:
        os_finish_res = saltapi.saltCmd(ping_params)
        enabled = True
        for host in saltapi.getHostlist():
              if not os_finish_res[0].get(host,False):
                  enabled = False

        if enabled:
            print "The deployment of cloud in a box is beginning!"
            saltapi.saltCmd(deploy_params) 
            print "Finished!"
            sys.exit(1)       
        
        time.sleep(10)


if __name__ == '__main__':
   main()
