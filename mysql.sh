#!/bin/bash

source ./common.sh

check_root

echo "please enter DB password:"
read -s mysql_root_password

dnf install mysql-server -y &>>$LOGFILE

systemctl enable mysqld &>>$LOGFILE

systemctl start mysqld &>>$LOGFILE

mysql -h db.mydaws.online -u root -p${mysql_root_password} -e 'show databases' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
else
    echo -e "MySQL root password already set...$Y SKIPPING $N"
fi