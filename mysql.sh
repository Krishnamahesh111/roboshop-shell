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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disable current MySQL version"

cp mysql.repo /etc/yum.repos.d/mysql.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Copied MySQL repo"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting MySQL Server"

mysql_secure_installation --set-root-pass Roboshop@1 &>> $LOGFILE

VALIDATE $? "Setting MySQL root password"



