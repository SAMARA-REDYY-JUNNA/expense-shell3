#!/bin/bash

source ./common.sh
check_root

echo "please enter DB password:"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "creating expense user"
else
    echo -e "expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading backend.code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "extracted backend.code"

npm install &>>$LOGFILE
VALIDATE $? "installing nodejs dependencies"

cp /home/ec2-user/expense-shell3/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copied backend.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "installing mysql client"

mysql -h db.mydaws.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "restarting backend"
