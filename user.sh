#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.daws76s.website

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/"$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $? -ne 0 ]
then
    echo -e "$R ERROR:: Please run this scrpit with root acces $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enable NodeJS 18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS:18"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exit $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloding user application"

cd /app

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping User"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host mongodb.daws76s.website </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into MongoDB"
