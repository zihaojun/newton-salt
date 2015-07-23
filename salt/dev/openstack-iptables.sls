iptables-init:
   salt.state:
       - tgt: '*'
       - sls:
         - dev.iptables
