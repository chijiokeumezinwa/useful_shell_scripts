#!/bin/bash

#This script is supposed to crawl through your files
#and make a list of the files written in past month
#and send an email based on this report
#Create output file, override if already present  
# echo $(cd ../ && echo "${PWD##*/}:") > output_file.txt
printf "~~Most Recent Backups~~" > output_file.txt
printf "\n\n" >> output_file.txt

#loop through parent directory and call ls -lh on most recent files

for name in ../*/ ; do
    if [ -d $name ] ; then
        #echo "${name/..\/}:" removes the dots
        #sed 's|/||g' removes the slash
        if [ "$name" == "../alpr-db-ocso/" ] ; then
            continue
        fi
        echo "${name/..\/}:" | sed 's|/||g' >> output_file.txt

        # ls -lh $name | grep "$(date '+%b %e')" | grep '\.zip$' | awk '{print $9, $5, $6, $7, $8}'  >> output_file.txt

        ls -lh --time-style='+%Y %b %e %R' $name | grep "$(date '+%Y %b %e')" | grep '\.zip$' | awk '{print $10, $5, $7, $8, $9}' >> output_file.txt
        printf "\n\n" >> output_file.txt
    fi
done

#send email
SERVER="smtp.example_company.net"
PORT="465"
USER="alertsystem@example_company.net"
PASS='examplepassword'
SENDER_ADDRESS="alertsystem@example_company.net"
SENDER_NAME="alertsystem"


    
RECIPIENT_NAME='Chijioke'
RECIPIENT_ADDRESS='chijioke@example_company.net'
TODAY_DATE=$(date)
SUBJECT='Remote Back up Report'
MESSAGE=$(cat output_file.txt)

printf "From: $SENDER_NAME <$SENDER_ADDRESS>\nTo: $RECIPIENT_NAME <$RECIPIENT_ADDRESS>\n\
Subject: $SUBJECT $TODAY_DATE\nDate: $TODAY_DATE\n\n$MESSAGE\n" > output_file_copy1.txt


curl --ssl-reqd --url "smtps://$SERVER:$PORT" \
    --upload-file output_file_copy1.txt\
    --user "$USER:$PASS" \
    --mail-from "$SENDER_ADDRESS" \
    --mail-rcpt "$RECIPIENT_ADDRESS" 

 