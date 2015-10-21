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
ENV MEDIAWIKI_VERSION 1.23
ENV MEDIAWIKI mediawiki-1.23.11

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

# Activea Apache PHP5 module
RUN a2enmod php5

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
		
#*********************************************************************
#* Expose relevant ports
#*********************************************************************
# http
EXPOSE 80
# https 
EXPOSE 443
# mysql 
EXPOSE 3306
