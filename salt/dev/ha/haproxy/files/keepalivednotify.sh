#!/bin/bash
#function: The script is called after any state change with the following parameters
# $1 = “GROUP” or “INSTANCE”
# $2 = name of group or instance
# $3 = target state of transition (“MASTER”, “BACKUP”, “FAULT”)

TYPE=$1 
NAME=$2
STATE=$3

case $STATE in
        "MASTER") 
             systemctl start haproxy
                  exit 0
                  ;;

        "BACKUP") 
             systemctl stop haproxy
                  exit 0
                  ;;

        "FAULT")  
             systemctl stop haproxy
                  exit 0
                  ;;

        *)        
             echo "Unknown state"
                  exit 1
                  ;;
esac
