#!/bin/bash
sudo yum install -y cronie
sudo systemctl start crond
sudo systemctl enable crond
SCRIPT_TO_SCHEDULE="/home/ec2-user/Check_Tomcat.sh"
chmod +x $SCRIPT_TO_SCHEDULE
CRON_JOB="0 6 * * 1-5 $SCRIPT_TO_SCHEDULE"
crontab -l > mycron
echo "$CRON_JOB" >> mycron
crontab mycron
rm mycron
echo "Scheduled $SCRIPT_TO_SCHEDULE to run at 6AM every weekday."
