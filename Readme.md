# docker-mediawiki
Ubuntu MediaWiki container with fully automated install. 
Will get your MediaWiki running in a few minutes.

See  https://www.mediawiki.org/wiki/MediaWiki

## Features
* Ubuntu 14.04 based LAMP Docker container
* Installs Linux, Apache, MySQL, PHP5 
* by default creates MySQL and MediaWiki SysOp password randomly
* Installs MediaWiki with LocalSettings already configured (step can be ommitted)
* optionally installs Composer
* optionally installs Semantic MediaWiki
* build/run scripts included to start immediately

### Documentation
* [Wiki]  https://github.com/BITPlan/docker-mediawiki/wiki

## Installation
* get your Docker installation up and running https://docs.docker.com/installation/
### default installation
* run the following commands in a shell/terminal:
```
git clone https://github.com/BITPlan/docker-mediawiki
cd docker-mediawiki
./build
./run
```
* point your browser to 
  http://ip-address
for the apache default page
  http://ip-address/mediawiki
for the mediawiki installation
* login with
user: Sysop
password: as displayed by the run script

the ip-address is shown at the start of "run".

* If you add
```
docker <ip-address>
```
to your /etc/hosts file

you can browse to the mediawiki via the url
http://docker/mediawiki

### installation options
```
./run -h
```

will show you the installation options
```
docker-mediawiki
	see https://github.com/BITPlan/docker-mediawiki

options: 
       -h|--help             : show this usage
    -nols|--no_local_settings: skip automatic creation of LocalSettings.php
-composer|--composer         : install composer
     -smw|--smw              : install Semantic MediaWiki
```

## Project info
* Mediawiki 1.23 based
* Apache License

## Version history
* 0.0.1 - 2015-10 first Version


