#!/bin/bash

source ./common.sh
check_root

echo "please enter DB password:"
read -s mysql_root_password

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$LOGFILE

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading frontend.code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "extracted frontend.code"

cp /home/ec2-user/expense-shell2/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "copied expense.conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "restarting nginx"

