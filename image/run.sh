# Copyright (c) 2015 BITPlan GmbH
#
# see LICENSE
#
# WF 2015-10-23
#
# entry point for existing docker image
#
# this would be how it works on other linuxes:
# exec httpd -D FOREGROUND 
# ubuntu is different
# http://koansys.com/news/run-apache-in-the-forground-on-ubuntu
service mysql start
. /etc/apache2/envvars;
apache2 -X
