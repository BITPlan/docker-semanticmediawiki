# docker-mediawiki
Ubuntu MediaWiki container with fully automated install. 

See  https://www.mediawiki.org/wiki/MediaWiki

## Features
* Ubuntu 14.04 based Docker container
* Installs Apache, MySQL, PHP5 
* creates MySQL and MediaWiki SysOp password randomly
* Installs MediaWiki with LocalSettings already configured
* build/run scripts included to start immediately

## Installation
* get your Docker installation up and running https://docs.docker.com/installation/
```
git clone https://github.com/BITPlan/docker-mediawiki
cd docker-mediawiki
./build
./run
```
point your browser to 
  http://ip-address
for the apache default page
  http://ip-address/mediawiki
for the mediawiki installation
login with
user: Sysop
password: as displayed by the run script

the ip-address is shown at the start of "run".

If you add
docker <ip-address>

to your /etc/hosts file

you can browse to the mediawiki via the url
http://docker/mediawiki

## Project info
* Mediawiki 1.23 based
* Apache License

## Version history
* 0.0.1 - 2015-10 first Version


