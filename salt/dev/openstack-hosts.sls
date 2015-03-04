hosts-init:
   salt.state:
       - tgt: '*' 
       - sls:
         - dev.openstack.hosts


