#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.daws.website

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

VALIDATE $? "Enabling NodeJS:18"

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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloding catalouge application"

cd /app

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

# use absolute, because catalouge.service exists there
cp /home/centos/roboshop-shell/catalouge.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Copying catalouge service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalouge daemon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalouge data into MongoDB"














