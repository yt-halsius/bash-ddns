# bash-ddns
Bash script to update DNS server from Swedish DNS-Server provider Glesys and Loopia
#
First edit the ddns_install and uncomment line 2 if you want crontab to update Loopia DNS or line 3 if you want crontab to update Gleys DNS, if you want to update both from the same server you need two scripts for the time beeing.
Edit the file called ddns.sh, change the apipass and apiuser, when updating Loopia DNS you also need to change the hostname. For glesys you need to know the record ID for the dns-record you want to update dynamically.
Run the file called ddns_install.sh to get started. This will copy the script to a safe place within your server and add a job to Crontab.
#
In short to get this script up and running, you need to do:
1. Edit the file called ddns.sh and for Loopia DNS edit: apiuser, apipass and hostname.
1. Edit the file called ddns.sh and for Glesys DNS edit: apiuser, apipass and recordid
2. Edit the file called ddns_install.sh and uncomment row 2 if you're using Loopia DNS or row 2 if you're using Glesys DNS.
3. Run ddns_install.sh --> This will install a crontab job and copy the script to /usr/local/bin .
#
If you dont want the script running using crontab you can use the script direcly from the command line using ./
The script accepts four diffrent arguments, theese are:
-L --Runs the script for Loopia DNS Server
-G --Runs the script for Glesys DNS Server
-P --Print the actual WAN-IP and the Last known WAN-IP
-H --Prints the usage information.

#
Disclamer!
Because the install script installs a job in the crontab, make sure that you backup the users crontab before proceeding!
Even if the installer is made to check for existing crontab jobs and ammend jobs to it, the best practice is to back it up before use!

2021-01-23
yt-halsius
