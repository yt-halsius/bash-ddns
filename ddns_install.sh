#!/bin/bash
#Made by: yt-halsius 2021-01-23
#Made with bluefish and vim
#arg=-L #Uncomment this line to run the script for Loopia DNS
#arg=-G #Uncomment this line to run the script for Glesys DNS
#Check if the script is running as root, as we need to be able to write to /usr/local/bin
if (( $EUID != 0 )); 
then
echo "You need to be root to run this"
#Write somthing to log for debugging purposes
logger "DDNS Install Failed, User not root "
exit
else
#Make sure the ddns.sh script has the "X" flag on it
chmod +x ddns.sh
#Create the file waniphistory for the script updatedns to use
echo " " > /usr/local/bin/waniphistory
#Move the update script away to /usr/local/bin for safekeeping
mv ddns.sh /usr/local/bin/ddns.sh
#Get cron status so we can check for any entries in it, otherwise we can install our script directly without ammending file
cmd=$(crontab -l > /dev/null 2>&1)   
echo "Checking cron status, please wait..."
#echo " "
#echo $cmd
if [ "$cmd" == "" ]
then
echo " "
echo "......................................"
echo " "
echo "Crontab empty; installing new cron job"
echo " "
#Insert new cron job into cron file
echo "0 * * * * /usr/local/bin/ddns.sh $arg" > mycron
#Install new cron file
crontab mycron
#Remove swap cron file
rm mycron
#Write somthing to log for debugging purposes
logger "DDNS Installed, no previus cron jobs was present"
/usr/local/bin/ddns.sh $arg
else
echo " "
echo "......................................"
echo " "
echo "Jobs in cron, backing up and installing"
echo " "
#Write out current Cron
crontab -l > mycron
#Insert new cron job into cron file
echo "0 * * * * /usr/local/bin/ddns.sh $arg" >> mycron
#If another running intervall is needed please change above but keeping the format
#See https://crontab.guru/#0_*_*_*_* for more information
#Install new cron file
crontab mycron
#Remove swap cron file
rm mycron
#Write somthing to log for debugging purposes
logger "DDNS Installed, previus cron jobs was present"
/usr/local/bin/ddns.sh $arg
fi
fi
