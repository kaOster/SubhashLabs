#!/bin/bash
# Install Apache
yum update -y
yum install -y httpd
# Start Apache
systemctl start httpd
systemctl enable httpd
# Create a simple webpage
echo "<html><body><h1>Hello, World</h1></body></html>" > /var/www/html/index.html
