#!/bin/bash
yum update -y
amazon-linux-extras install java-openjdk11 -y
yum install tomcat tomcat-webapps tomcat-admin-webapps -y
systemctl start tomcat
systemctl enable tomcat
