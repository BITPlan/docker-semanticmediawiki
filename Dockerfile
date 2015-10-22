#*********************************************************************
#
# Copyright (c) 2015 BITPlan GmbH
# 
# see LICENSE
#
# Dockerfile to build MediaWiki server 
# Based on ubuntu 
#
#*********************************************************************

# Ubuntu image
FROM ubuntu:14.04

# 
# Maintained by Wolfgang Fahl / BITPlan GmbH http://www.bitplan.com
# 
MAINTAINER Wolfgang Fahl info@bitplan.com

#*********************************************************************
# Settings
#*********************************************************************

# MEDIAWIKI LTS Version
# https://www.mediawiki.org/wiki/MediaWiki_1.23
# LTS
ENV MEDIAWIKI_VERSION 1.23
ENV MEDIAWIKI mediawiki-1.23.11

# see https://www.mediawiki.org/wiki/Download
# as of 2015-10-22:
# LEGACY: 1.24.4
# STABLE: 15.3

# Semantic Mediawiki Version (optional install)
# see https://semantic-mediawiki.org
# and https://semantic-mediawiki.org/wiki/Help:Installation/Using_Composer_with_MediaWiki_1.22_-_1.24
# Please always omit the bugfix release number, i.e. the third number.
ENV SMW_VERSION 2.2

#*********************************************************************
# Install Linux Apache MySQL PHP (LAMP)
#*********************************************************************

# see https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Ubuntu 
RUN \
  apt-get install -y \
	apache2 \
	curl \
	dialog \
	git \
	libapache2-mod-php5 \
	mysql-server \
	php5 \
	php5-cli \
	php5-gd \
	php5-mysql
		
# see https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki
RUN cd /var/www/html/ && \
  curl -O https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/$MEDIAWIKI.tar.gz && \
	tar -xzvf $MEDIAWIKI.tar.gz && \
	rm *.tar.gz

# Activate Apache PHP5 module
RUN a2enmod php5

# Copy the install script
COPY ./image/docker-entrypoint.sh /

# Use it as an entry point
ENTRYPOINT ["/docker-entrypoint.sh"]

# COPY run script to be used as an entrypoint after installation
COPY ./image/run.sh /
		
#*********************************************************************
#* Expose relevant ports
#*********************************************************************
# http
EXPOSE 80
# https 
EXPOSE 443
# mysql 
EXPOSE 3306
