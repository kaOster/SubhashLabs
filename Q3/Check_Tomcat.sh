#!/bin/bash
if systemctl is-active --quiet tomcat; then
  echo "Tomcat is running."
else
  echo "Tomcat is not running. Starting Tomcat..."
  sudo systemctl start tomcat
fi
