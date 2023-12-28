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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Downloading rabbitmg script"

dnf install rabbitmq-server -y &>> $LOGFILE

VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>> $LOGFILE

VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server &>> $LOGFILE

VALIDATE $? "Starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

VALIDATE $? "Creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "setting permission"