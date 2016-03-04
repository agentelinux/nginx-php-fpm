#!/bin/bash
# This script will update the env.list file (file containing USERS environrment variable) and add the new users if there are any.
# Will check for new users at a given time interval (change sleep duration on line 33)

FTP_DIRECTORY="/home/public"
SLEEP_DURATION=60
username="public"
# Change theses next two variables to set different permissions for files/directories
# These were default from vsftpd so change accordingly if necessary
FILE_PERMISSIONS=644
DIRECTORY_PERMISSIONS=755

add_users() {
    # If user account doesn't exist create it 
    # As well as their home directory 
    if ! getent passwd "$username" >/dev/null 2>&1; then
       useradd -d "$FTP_DIRECTORY/$username" -s /usr/sbin/nologin $username
       usermod -G ftpaccess $username
       echo "Xc4Eld20Plo" | chpasswd -e

       mkdir -p "$FTP_DIRECTORY/$username"
       chown root:ftpaccess "$FTP_DIRECTORY/$username"
       chmod 750 "$FTP_DIRECTORY/$username"

       echo "$username" > /etc/vsftpd/vsftpd.userlist
       chown $username:ftpaccess "$FTP_DIRECTORY/$username/files"
       chmod 750 "$FTP_DIRECTORY/$username/files"
     fi
   done
}

 while true; do
   add_users
   sleep $SLEEP_DURATION
 done

