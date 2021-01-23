#!/bin/bash
#Made by: yt-halsius 2021-01-23
#Made with bluefish and vim
#Script for ddns-update either using Glesys DNS-service or POS Loopia DNS
#Use -L or G for Loopia or Glesys
#
#When updating a Loopia domain, change apiuser, apipass & hostname!
#When updating a Glesys domain, change apiuser, apipass & recordid!
#
#Create a couple of variables so that we don't have to change the desired parameters in the record update code.
apiuser=ausernamegoeshere
apipass=somepasshere
recordid="1234567890123456789"
hostname=yourhostnamegoeshere
#Do not edit beyond this line if you don't know what you're doing
header=https://
quotes='"'
burl=dyndns.loopia.se
errcode="NONE"
stat="N/A"
#
#
#Give user info how to run script
usage () {
echo "Usage $0 [ -G Update Glesys domain] [-L Update LOOPIA domain] [-P Print actual WAN-IP and last known IP] [-H This help] " 1>&2
exit 0
}
#
#Abnormal exit function
abnormal_exit () {
echo "Usage $0 [ -G Update Glesys domain] [-L Update LOOPIA domain] [-P Print actual WAN-IP and last known IP] [-H Prints help]" 1>&2
echo "Failed with error message $errcode"
exit 1
}
#
#Failed update exit function
f_update () {
echo "Failed update with error message $errcode"
logger "DDNS Update Failed Code: $cmd"
exit 1
}
#
#Definition of "Glesys function"
glesys () {
cmd=$(curl -s -X POST --basic -u "$apiuser":"$apipass" --data-urlencode "recordid="$recordid"" --data-urlencode "data="$wanip"" -k https://api.glesys.com/domain/updaterecord/ | grep "code" ) > /dev/null
#Remove the <code> tags from the returned status code
codesplit=${cmd#*>}
codesplit=${codesplit%%<*}
#Check if the returned status code is 200 ("OK") or if no update is required the varible stat will be OK
if [ "$codesplit" == "200" ] || [ "$stat" == "OK" ]
then
errcode="UPDATE OK"
logger "DDNS Update OK"
exit 0
else
errcode="UPDATE NOK"
logger "DDNS Update Failed Code: $codesplit"
abnormal_exit
fi
}
#
#
#Definition of "Loopia function"
loopia () {
#cmd=$(curl --user "$apiuser":"$apipass" "https://dyndns.loopia.se?hostname=$hostname&myip=$wanip") #This is the baseline to work from...
cmd=$(curl -s --user "$apiuser":"$apipass" "$header$burl?hostname=$hostname&myip=$wanip") #This is working but isn't veary pretty...
if [ $cmd == "good" ]
then
#If everything is OK we can store our current address in file for later reference
echo $wanip > waniphistory
logger "DDNS Update OK"
exit 0
fi
if [ $cmd == "nochg" ] || [ $cmd == "911" ]
then
#If update failed for some reason, we set the variable errcode to pass the specific error in...
errcode=$cmd
#Run the function f_update
f_update
fi
}
#
#
#Definition of WAN-IP check function
#Get WAN ip and put into varible wanip
getwanip () {
#Do a reverse lookup of users WAN-IP (Hopefully not a NAT/PNAT-adress)
wanip=$(dig +short myip.opendns.com @resolver1.opendns.com)
#Read last known wan ip from file called waniphistory
wanhist=$(cat waniphistory)
#Check if IP has changed since last run,
if [ "$wanhist" == "$wanip" ]
then
#if actual IP is the same as the IP of last RUN do nothing, else:
stat="OK"
logger "DDNS checked WAN-IP - No Change"
exit 0
else
#set the stat varible to "UPDATE" this way we can handle it later (Maybe this will all become redunant because of the exit command efter status OK...
stat="UPDATE"
logger "DDNS checked WAN-IP - Running Update"
fi
}
#
#
#Function to let User print the WAN-IP
printwanip () {
echo ""
#Get wan ip and put into varible wanip
wanip=$(dig +short myip.opendns.com @resolver1.opendns.com)
#Print out the IP from dig above...
echo "Your WAN ip is: "
echo $wanip
#Read last known wan ip from file called waniphistory
wanhist=$(cat waniphistory)
#Print out last known IP.
echo "Your last known WAN ip was: "
echo $wanhist
#
#Blank line just for some shits and giggles :O
echo " "
exit 0
}
#
#Check for flags...
#Run function getwanip to determine actual WAN-IP
getwanip
while getopts "LGPH" option;
do
	case "${option}"
		in
		G)#When the option G is given, we update Glesys DNS
		echo "Updating Glesys DNS"
		glesys
		;;
		L)#When the option L is given, we update Loopia DNS
		echo "Updating Loopia DNS"
		loopia
		;;
		P)#Print WAN-IP and last known WAN-IP
		printwanip
		;;
		H)#Print Usage information
		usage
		;;
		*)#If anything else is given, we exit with error, using function abnormal exit!
		errcode="UNKONWN ARG"
		abnormal_exit
		;;
		esac
		done
		if [ $option == "?" ] #If no option is given, we exit with error, using function abnormal exit!
		then
		errcode="NOARG"
		abnormal_exit
		fi