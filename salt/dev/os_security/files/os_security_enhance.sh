#!/bin/bash
# description: os security enhance

# variables define
USERNAME='openstack'
PASSWORD='YVB3B@d%i'

useradd $USERNAME -b /home -m -s /bin/bash
echo "${USERNAME}:${PASSWORD}" | chpasswd

cat > /etc/sudoers.d/50_openstack_sh << EOF
$USERNAME ALL=(root) PASSWD:ALL
Defaults:$USERNAME secure_path=/sbin:/usr/sbin:/usr/bin:/bin:/usr/local/sbin:/usr/local/bin
Defaults:$USERNAME timestamp_timeout=2,runaspw,passwd_tries=2
Defaults:$USERNAME requiretty  # whether need tty
EOF

sed -i -r 's/#(PermitRootLogin).*/\1 no/g' /etc/ssh/sshd_config
systemctl restart sshd

sed -i -r 's/(PASS_MIN_LEN).*/\1\t8/g' /etc/login.defs

chmod 744  /bin/mount
chmod 744  /bin/umount
chmod 744  /bin/login
chmod 744  /bin/ping 
chmod 744  /usr/bin/chfn
chmod 744  /usr/bin/chsh
chmod 744  /usr/bin/newgrp
chmod 744  /usr/bin/crontab  

mv /etc/issue /etc/issuebak
mv /etc/issue.net /etc/issue.netbak
touch  /etc/issue
touch  /etc/issue.net

cat > /etc/host.conf << EOF
order bind,hosts
multi off
nospoof on
EOF

cat >> /etc/security/limits.conf << EOF
* hard core 0
* hard rss  5000
EOF

echo "session required /lib64/security/pam_limits.so" >> /etc/pam.d/login 

groupdel  adm
groupdel  games
userdel adm
userdel lp
userdel sync
userdel shutdown
userdel halt
userdel operator
userdel games

chattr +i /etc/services
chattr +i  /etc/passwd
chattr +i  /etc/shadow
chattr +i  /etc/group

sed -i '/^[^tty*]/d' /etc/securetty

echo "net.ipv4.tcp_syn_retries=5" >> /etc/sysctl.conf
echo "1" > /tmp/os_security_finished
