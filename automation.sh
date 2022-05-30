#!/bin/bash

# Declare variables
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="sumeet"
s3_bucket="upgrad-sumeet"
sudo apt update -y

# Install and start apache
sudo apt-get install apache2
servstat=$(service apache2 status)
if [[ $servstat == *"active (running)"* ]]; then
  echo "process is already running"
else
  sudo systemctl start apache2
fi
sudo systemctl status apache2
if (sudo systemctl status apache2.service | grep 'disabled');
then
	sudo systemctl enable apache2.service
fi

# Archive logs
cd /tmp/
tar -czvf ${myname}-httpd-logs-${timestamp}.tar.gz /var/log/apache2/*.log

# Installing awscli 
sudo apt update
sudo apt install awscli

# Copy logs to S3 Bucket 
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

if [[ ! -e /var/www/html/inventory.html ]]; then
    mkdir -p /html
    touch /var/www/html/inventory.html
	echo "Log Type               Date Created               Type      Size" >> /var/www/html/inventory.html
fi

cd /tmp/
ls -l| grep *.tar| awk '{print $6,$7,$8,$9}' >> /var/www/html/inventory.html
