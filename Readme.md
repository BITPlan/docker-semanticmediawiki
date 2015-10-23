# docker-semanticmediawiki
Ubuntu Semantic MediaWiki container with fully automated install. 
Will get your Semantic MediaWiki running in a few minutes.

See http://www.semantic-mediawiki.org/
See  https://www.mediawiki.org/wiki/MediaWiki

## Features
* Ubuntu 14.04 based LAMP Docker container
* Installs Linux, Apache, MySQL, PHP5 
* by default creates MySQL and MediaWiki SysOp password randomly
* Installs MediaWiki with LocalSettings already configured (step can be ommitted)
* installs Composer
* installs Semantic MediaWiki
* build/run scripts included to start immediately

### Documentation
* [Wiki]   https://github.com/BITPlan/docker-semanticmediawiki/wiki
* [FAQ]    https://github.com/BITPlan/docker-semanticmediawiki/wiki#FAQ
* [Issues] https://github.com/BITPlan/docker-semanticmediawiki/issues

## Installation
* get your Docker installation up and running https://docs.docker.com/installation/
### default installation
* run the following commands in a shell/terminal:
```
git clone https://github.com/BITPlan/docker-semanticmediawiki
cd docker-semanticmediawiki
./build
./run
```
* point your browser to 
  http://smw
for the apache default page
  http://smw/mediawiki
for the mediawiki installation
* login with
user: Sysop
password: as displayed by the build script

the ip-address for "smw" is optionally added at the start of "run" to your /etc/hosts file.

## Project info
* Mediawiki 1.23 based
* Apache License

## Version history
* 0.0.1 - 2015-10-22 first Version


