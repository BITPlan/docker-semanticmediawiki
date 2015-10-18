#*********************************************************************
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

RUN \
  apt-get install -y php5 apache2 mysql-server curl
		
		
RUN cd /var/www/html/ && \
	curl -O https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/$MEDIAWIKI.tar.gz && \
	tar -xzvf $MEDIAWIKI.tar.gz && \
	rm *.tar.gz
		
		
#*********************************************************************
#* Expose relevant ports
#*********************************************************************
# http
EXPOSE 80
# https 
EXPOSE 443
# mysql 
EXPOSE 3306
		
