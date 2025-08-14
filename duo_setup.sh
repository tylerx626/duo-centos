#!/bin/bash

#This script will download, install, and configure Duo MFA for CentOS 7.x minimalservers
#Official instructions here https://duo.com/docs/duounix#install-pam_duo

#Create /etc/yum.repos.d/duosecurity.repo with the following contents:

echo "[duosecurity]" > /etc/yum.repos.d/duosecurity.repo
echo "name=Duo Security Repository" >> /etc/yum.repos.d/duosecurity.repo
echo "baseurl=https://pkg.duosecurity.com/CentOS/\$releasever/\$basearch" >> /etc/yum.repos.d/duosecurity.repo
echo "enabled=1" >> /etc/yum.repos.d/duosecurity.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/duosecurity.repo


#Execute the following shell commands for Centos 6 and later:
rpm --import https://duo.com/DUO-GPG-PUBLIC-KEY.asc
yum install -y duo_unix


#edit /etc/duo/pam_duo.conf with ikey, secret key, and hostname
#prompt user for input and add config below...

echo "Enter the Duo integration key..."
read ikey
echo "Enter the Duo secret key..."
read skey
echo "Enter the Duo API hostname..."
read host

echo "[duo]" > /etc/duo/pam_duo.conf
echo "; Duo integration key" >> /etc/duo/pam_duo.conf
echo "ikey =" $ikey >> /etc/duo/pam_duo.conf
echo "; Duo secret key" >> /etc/duo/pam_duo.conf
echo "skey =" $skey >> /etc/duo/pam_duo.conf
echo "; Duo API host" >> /etc/duo/pam_duo.conf
echo "host =" $host >> /etc/duo/pam_duo.conf
echo "failmode = safe" >> /etc/duo/pam_duo.conf
echo "autopush = no" >> /etc/duo/pam_duo.conf
echo "prompts = 2" >> /etc/duo/pam_duo.conf
echo "https_timeout=60" >> /etc/duo/pam_duo.conf

#make copy of sshd_config an replace with Duo config added
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
sudo cp duo-centos/duo_sshd_config /etc/ssh/sshd_config

#make copy of PAM sshd and replace with Duo config added
sudo cp /etc/pam.d/sshd /etc/pam.d/sshd.old
sudo cp duo-centos/duo_pamd_sshd /etc/pam.d/sshd

#make copy of PAM system-auth and replace with Duo config added
sudo cp /etc/pam.d/system-auth /etc/pam.d/system-auth.old
sudo cp duo-centos/duo_pamd_system-auth /etc/pam.d/system-auth

#SELinux may block PAM from contacting Duo, so adjust to allowing outgoing HTTP connections
sudo make -C /opt/duo_unix_latest/pam_duo semodule
sudo make -C /opt/duo_unix_latest/pam_duo semodule-install

#verify semodule includes Duo
semodule -l | grep duo



#Now test and make sure auth is working from another session. Do not close out the session you are working from without testing!!

