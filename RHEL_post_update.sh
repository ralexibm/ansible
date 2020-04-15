#!/bin/bash

## Variables

PATH_DIR=/var/log/checklist
BACKUP_DIR=POST-UPDATE-$(date +'%Y-%m-%d_%H-%M')

DIR_LOGFILES=$PATH_DIR/$BACKUP_DIR

echo -e "\nStarting the pre-check update in the $(hostname)\n"
sleep 2
echo -e "Creating backup some server configuration...\n"
sleep 2

## Creating directory to save the files
mkdir -p $DIR_LOGFILES

## CRON Backup
echo -e "Cron... \n"

ls /var/spool/cron/ > $DIR_LOGFILES/cron.users
exec 3< $DIR_LOGFILES/cron.users

while read USER <&3; do
	echo " " >> $DIR_LOGFILES/cron.bkp
	echo -e "Crontab do Usuario $USER" >> $DIR_LOGFILES/cron.bkp
        cat /var/spool/cron/$USER >> $DIR_LOGFILES/cron.bkp
        echo -e "\n\n\n " >> $DIR_LOGFILES/cron.bkp
done
exec 3<&-

rm -rf $DIR_LOGFILES/cron.users

## NFS Backup
if [ -f /etc/exports ]
then
	echo -e "NSF... \n"	
	cat /etc/exports >> $DIR_LOGFILES/exports.bkp
fi

## NTP Backup
if [ -e "/etc/ntp.conf" ]
then
	echo -e "NTP... \n"
	cat /etc/ntp.conf |grep server >> $DIR_LOGFILES/ntp.bkp
fi

## Sysctl Backup
echo -e "Sysctl... \n"
sysctl -a 2>/dev/null >> $DIR_LOGFILES/sysctl.bkp

## Memory
echo -e "Memory... \n"
free -m >> $DIR_LOGFILES/memory-details.bkp

## Date
echo -e "Date... \n"
date >> $DIR_LOGFILES/date.bkp


## Uptime
echo -e "Uptime... \n"
uptime >> $DIR_LOGFILES/uptime.bkp

## Kernel
echo -e "Kernel... \n"
uname -rsm >> $DIR_LOGFILES/kernel.bkp

## chkconfig
echo -e "Chkconfig... \n"
chkconfig --list 2>/dev/null >> $DIR_LOGFILES/chkconfig.bkp

## HOSTS
echo -e "Hosts... \n"
cat /etc/hosts >> $DIR_LOGFILES/hosts.bkp

## Resolv.conf
if [ -e "/etc/resolv.conf" ]
then
	echo -e "Resolv.conf... \n"
	cat /etc/resolv.conf >> $DIR_LOGFILES/resolv.conf.bkp
fi

## Devices
echo -e "Devices... \n"
lspci >> $DIR_LOGFILES/lspci-DEVICES.bkp

## Inittab
if [ -e "/etc/inittab" ]
then
	echo -e "inittab... \n"
	cat /etc/inittab >> $DIR_LOGFILES/inittab.bkp
fi

## Netstat
echo -e "netstat... \n"
netstat -taupen >> $DIR_LOGFILES/netstat.bkp

## Active route tables
echo -e "Active route tables... \n"
route -n >> $DIR_LOGFILES/route.bkp

## ifconfig
echo -e "Ifconfig... \n"
ifconfig >> $DIR_LOGFILES/ifconfig.bkp

## RPM
echo -e "RPM packages installed... \n"
rpm -qa --queryformat='(%{installtime:date}) %{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}.rpm \n'| sort -b -k8,8 >> $DIR_LOGFILES/rpm.bkp

## OS release
echo -e "OS release... \n"
cat /etc/*release >> $DIR_LOGFILES/os_release.bkp

## File systems mounted
echo -e "File systems mounted... \n"
df -mTP | sort | grep -v "$(df -mTP|head -1)" >> $DIR_LOGFILES/file_systems.bkp

## FSTAB
if [ -e "/etc/fstab" ]
then
	echo -e "FSTAB... \n"
	cat /etc/fstab >> $DIR_LOGFILES/fstab.bkp
fi

## List of active Modules
echo -e "List of active Modules... \n"
lsmod | awk '{ print $1 }' | sort >> $DIR_LOGFILES/lsmod.bkp

## LVS
echo -e "LVS... \n"
lvs 2>/dev/null >> $DIR_LOGFILES/lvs.bkp

## PV List
echo -e "PV list... \n"
pvs 2>/dev/null >> $DIR_LOGFILES/pvs.bkp

## VGS
echo -e "VGS... \n"
vgs >> $DIR_LOGFILES/vgs.bkp

## lsblk
echo -e "lsblk... \n"
lsblk >> $DIR_LOGFILES/lsblk.bkp

## blkid
echo -e "blkid... \n"
blkid >> $DIR_LOGFILES/blkid.bkp

## lscpu
echo -e "lscpu... \n"
lscpu >> $DIR_LOGFILES/lscpu.bkp

## Last
echo -e "last... \n"
last >> $DIR_LOGFILES/last.bkp

## PAM.D
echo -e "pam.d... \n"
ls /etc/pam.d/ > $DIR_LOGFILES/pam.files
exec 3< $DIR_LOGFILES/pam.files

while read FILES <&3; do
	echo -e "#####################################################################################\n\n\n" >> $DIR_LOGFILES/pam_d.bkp
        echo -e "/etc/pam.d/$FILES" >> $DIR_LOGFILES/pam_d.bkp
        cat /etc/pam.d/$FILES >> $DIR_LOGFILES/pam_d.bkp
        echo -e "\n\n\n " >> $DIR_LOGFILES/pam_d.bkp
done
exec 3<&-

rm -rf $DIR_LOGFILES/pam.files

## Active processes
echo -e "Active processes... \n"
ps auxf >> $DIR_LOGFILES/processes.bkp

## Postfix
echo -e "Postfix... \n"
postconf >> $DIR_LOGFILES/postfix.bkp

## PASSWD
if [ -e "/etc/passwd" ]
then
	echo -e "Passwd... \n"
	cat /etc/passwd >> $DIR_LOGFILES/passwd.bkp
fi

## GROUP
if [ -e "/etc/group" ]
then
	echo -e "Group... \n"
	cat /etc/group >> $DIR_LOGFILES/group.bkp
fi

## SHADOW
if [ -e "/etc/shadow" ]
then
        echo -e "Shadow... \n"
        cat /etc/shadow >> $DIR_LOGFILES/shadow.bkp
fi

echo -e "Backup has been finalized and saved in $DIR_LOGFILES \n"
