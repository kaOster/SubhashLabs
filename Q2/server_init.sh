#!/bin/bash
yum update -y
yum install -y python3
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
pip3 install boto3