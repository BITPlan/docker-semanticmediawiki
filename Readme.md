# docker-semanticmediawiki
![Mediawiki](https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/MediaWiki_logo_1.png/128px-MediaWiki_logo_1.png)
![SemanticMediaWiki](http://semantic-mediawiki.org/w/images/7/7c/SMW_logo_142px.png)

Ubuntu Semantic MediaWiki container with fully automated install. 
Will get your Semantic MediaWiki running in a few minutes.

* See http://www.semantic-mediawiki.org/
* See  https://www.mediawiki.org/wiki/MediaWiki
* see https://github.com/SemanticMediaWiki/SemanticMediaWiki/issues/1218

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
* you might want to make sure that you have at least version 1.8.3

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

The imagehostname is now set to your hostname by default assuming a linux environment.
So replace "smw" with your own hostname e.g. if you run on www.example.com the result will be available
at http://www.example.com/mediawiki


## Running and stopping your container
The run script has three modes
* initially it runs the container to start mysql / apache
* if the container exists and runs it will open a shell
* if the container exists and does not run it will start it and open a shell

## Project info
* Mediawiki 1.23 based
* Apache License

## Version history
* 0.0.1 - 2015-10-22 first Version
* 0.0.2 - 2016-01-25 fixes #7 and upgrades to Mediawiki 1.23.13
* 0.0.3 - 2018-12-29 fixes #8 and upgrades to Ubuntu 16.04, Mediawiki 1.27.5 and PHP 7.0

