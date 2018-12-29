#!/bin/bash
#
# Copyright (c) 2015-2018 BITPlan GmbH
#
# see LICENSE
#
# WF 2015-10-18
# 
# Mediawiki docker image entrypoint script
#
# see
# https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki
# 
# do not uncomment this - it will spoil the $? handling
#set -e

#ansi colors
#http://www.csc.uvic.ca/~sae/seng265/fall04/tips/s265s047-tips/bash-using-colors.html
blue='\e[0;34m'
red='\e[0;31m'
green='\e[0;32m' # '\e[1;32m' is too bright for white bg.
endColor='\e[0m'

#
# a colored message 
#   params:
#     1: l_color - the color of the message
#     2: l_msg - the message to display
#
color_msg() {
  local l_color="$1"
	local l_msg="$2"
	echo -e "${l_color}$l_msg${endColor}"
}

#
# error
#
#   show an error message and exit
#
#   params:
#     1: l_msg - the message to display
error() {
  local l_msg="$1"
	# use ansi red for error
  color_msg $red "Error: $l_msg" 1>&2
  exit 1
}

#
# show usage
#
usage() {
  echo "docker-mediawiki"
  echo "	see https://github.com/BITPlan/docker-mediawiki"
  echo ""
  echo "options: "
  # -h|--help|usage|show this usage
  echo "       -h|--help             : show this usage"
  echo "    -nols|--no_local_settings: skip automatic creation of LocalSettings.php"
  echo "-composer|--composer         : install composer"
  echo "     -smw|--smw              : install Semantic MediaWiki"
  exit 1
}

#
# generate a random password
#
random_password() {
  date +%N | sha256sum | base64 | head -c 16 ; echo
}

#
# get the database environment
#  params: 
#     1: l_settings - the Localsettings to get the db info from
#
#
getdbenv() {
  local l_settings="$1"
	# get database parameters from local settings 
	dbserver=`egrep '^.wgDBserver' $l_settings | cut -d'"' -f2`
	dbname=`egrep '^.wgDBname'     $l_settings | cut -d'"' -f2`
	dbuser=`egrep '^.wgDBuser'     $l_settings | cut -d'"' -f2`
	dbpass=`egrep '^.wgDBpassword' $l_settings | cut -d'"' -f2`
}

#
# do an sql command 
#  params: 
#     1: l_settings - the Localsettings to get the db info from
#
dosql() {
  # get parameters
	local l_settings="$1"
	# get database parameters from local settings 
	getdbenv "$l_settings"
	# uncomment for debugging mysql statement
	#echo mysql --host="$dbserver" --user="$dbuser" --password="$dbpass" "$dbname"
	mysql --host="$dbserver" --user="$dbuser" --password="$dbpass" "$dbname" 2>&1
}

#
# prepare mysql
#
prepare_mysql() {
  service mysql start
  MYSQL_PASSWD=`random_password`
	color_msg $blue "setting MySQL password to random password $MYSQL_PASSWD"
  mysqladmin -u root password $MYSQL_PASSWD
}

#
# check the Wiki Database defined in the  LocalSettings.php for the given site
#  params: 
#   1: settings - the LocalSettings path e.g /var/www/html/mediawiki/LocalSettings.php
#
checkWikiDB() {
  # get parameters
  local l_settings="$1"
  color_msg $blue "checking Wiki Database"
    
  # check mysql access
  local l_pages=`echo "select count(*) as pages from page" | dosql "$l_settings" `
  #
  # this will return a number of pages or a mysql ERROR
  #
  echo "$l_pages" | grep "ERROR 1049" > /dev/null
  if [ $? -ne 0 ]
  then
    # if the db does not exist or access is otherwise denied:
    # ERROR 1045 (28000): Access denied for user '<user>'@'localhost' (using password: YES)
	  echo "$l_pages" | grep "ERROR 1045" > /dev/null
	  if [ $? -ne 0 ]
	  then
	    # if the db was just created:
	    #ERROR 1146 (42S02) at line 1: Table '<dbname>.page' doesn't exist
	    echo "$l_pages" | grep "ERROR 1146" > /dev/null
	    if [ $? -ne 0 ]
	    then
	      # if everything was o.k.
	      echo "$l_pages" | grep "pages" > /dev/null
	      if [ $? -ne 0 ]
	      then 
	        # something unexpected
	        error "$l_pages"
	      else
	        # this is what we expect
	        color_msg $green "$l_pages"
	      fi
	    else
	      # db just created - fill it
	      color_msg $blue "$dbname seems to be just created and empty - shall I initialize it with the backup from an empty mediawiki database? y/n"
	      read answer
	      case $answer in
	        y|Y|yes|Yes) initialize $l_settings;;
	        *) color_msg $green "ok - leaving things alone ...";;
	      esac
	    fi
	  else
	    # something unexpected
	    error "$l_pages"
	  fi
	else
	  getdbenv "$l_settings"
	  color_msg $red  "$l_pages: database $dbname not created yet"
	  color_msg $blue "will create database $dbname now ..."
	  echo "create database $dbname;" | mysql --host="$dbserver" --user="$dbuser" --password="$dbpass" 2>&1
	  echo "grant all privileges on $dbname.* to $dbuser@'localhost' identified by '"$dbpass"';" | dosql "$l_settings"
	fi
}


#
# prepare mediawiki
#
#  params: 
#   1: settings - the LocalSettings path e.g /var/www/html/mediawiki/LocalSettings.php
# 
prepare_mediawiki() {
  local l_settings="$1"
	cat << EOF > $l_settings
<?php
# This file was automatically generated by the MediaWiki 1.23.11
# installer. If you make manual changes, please keep track in case you
# need to recreate them later.
#
# See includes/DefaultSettings.php for all configurable settings
# and their default values, but don't forget to make changes in _this_
# file, not there.
#
# Further documentation for configuration settings may be found at:
# https://www.mediawiki.org/wiki/Manual:Configuration_settings

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

## Uncomment this to disable output compression
# \$wgDisableOutputCompression = true;

\$wgSitename = "wiki";
\$wgMetaNamespace = "Wiki";

## The URL base path to the directory containing the wiki;
## defaults for all runtime URL paths are based off of this.
## For more information on customizing the URLs
## (like /w/index.php/Page_title to /wiki/Page_title) please see:
## https://www.mediawiki.org/wiki/Manual:Short_URL
\$wgScriptPath = "/mediawiki";
\$wgScriptExtension = ".php";

## The protocol and server name to use in fully-qualified URLs
\$wgServer = "http://$hostname";

## The relative URL path to the skins directory
\$wgStylePath = "\$wgScriptPath/skins";

## The relative URL path to the logo.  Make sure you change this from the default,
## or else you'll overwrite your logo when you upgrade!
\$wgLogo = "\$wgStylePath/common/images/wiki.png";

## UPO means: this is also a user preference option

\$wgEnableEmail = false;
\$wgEnableUserEmail = true; # UPO

\$wgEmergencyContact = "apache@localhost";
\$wgPasswordSender = "apache@localhost";

\$wgEnotifUserTalk = false; # UPO
\$wgEnotifWatchlist = false; # UPO
\$wgEmailAuthentication = true;

## Database settings
\$wgDBtype = "mysql";
\$wgDBserver = "localhost";
\$wgDBname = "wiki";
\$wgDBuser = "root";
\$wgDBpassword = "$MYSQL_PASSWD";

# MySQL specific settings
\$wgDBprefix = "";

# MySQL table options to use during installation or update
\$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=utf8";

# Experimental charset support for MySQL 5.0.
\$wgDBmysql5 = false;

## Shared memory settings
\$wgMainCacheType = CACHE_NONE;
\$wgMemCachedServers = array();

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
\$wgEnableUploads = true;
#\$wgUseImageMagick = true;
#\$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from http://commons.wikimedia.org
\$wgUseInstantCommons = false;

## If you use ImageMagick (or any other shell command) on a
## Linux server, this will need to be set to the name of an
## available UTF-8 locale
\$wgShellLocale = "C.UTF-8";

## If you want to use image uploads under safe mode,
## create the directories images/archive, images/thumb and
## images/temp, and make them all writable. Then uncomment
## this, if it's not already uncommented:
#\$wgHashedUploadDirectory = false;

## Set \$wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publically accessible from the web.
#\$wgCacheDirectory = "$IP/cache";

# Site language code, should be one of the list in ./languages/Names.php
\$wgLanguageCode = "en";

\$wgSecretKey = "16da25466b94b683dab67d4533e11e40e0f7b24a15aaab2b3ef5600143ce0007";

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
\$wgUpgradeKey = "80554160e8352086";

## Default skin: you can change the default skin. Use the internal symbolic
## names, ie 'cologneblue', 'monobook', 'vector':
wfLoadSkin('Vector');

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
\$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
\$wgRightsUrl = "";
\$wgRightsText = "";
\$wgRightsIcon = "";

# Path to the GNU diff3 utility. Used for conflict resolution.
\$wgDiff3 = "/usr/bin/diff3";

# The following permissions were set based on your choice in the installer
\$wgGroupPermissions['*']['createaccount'] = false;
\$wgGroupPermissions['*']['edit'] = false;
\$wgGroupPermissions['*']['read'] = false;

# Enabled Extensions. Most extensions are enabled by including the base extension file here
# but check specific extension documentation for more details
# The following extensions were automatically enabled:
require_once "\$IP/extensions/ParserFunctions/ParserFunctions.php";
require_once "\$IP/extensions/PdfHandler/PdfHandler.php";
require_once "\$IP/extensions/SyntaxHighlight_GeSHi/SyntaxHighlight_GeSHi.php";
require_once "\$IP/extensions/WikiEditor/WikiEditor.php";

# End of automatically generated settings.
# Add more configuration options below.
EOF
}

#
# installation of mediawiki
#
mediawiki_install() {
  local l_option="$1"
	color_msg $blue "Preparing Mediawiki $MEDIAWIKI_VERSION docker image"
	
	# set the Path to the Apache Document root
	apachepath=/var/www/html
	
	# set the Path to the Mediawiki installation (influenced by MEDIAWIKI ENV variable)
	mwpath=$apachepath/$MEDIAWIKI
  ln -s $mwpath $apachepath/mediawiki
	
	# MediaWiki LocalSettings.php path
	localsettings_dist=$mwpath/LocalSettings.php.dist
	localsettings=$mwpath/LocalSettings.php
	  
	# prepare mysql
	prepare_mysql
 
	# start the services
	service apache2 start
	
	# use the one created by this script instead
	if [ "$l_option" == "-nols" ]
	then
	  color_msg $blue "You choose to skip automatic creation of LocalSettings.php"
	  color_msg $blue "you can now install MediaWiki with the url http://$hostname/mediawiki"
	else
		# prepare the mediawiki
	  prepare_mediawiki $localsettings_dist
	
	  # make sure the Wiki Database exists
	  checkWikiDB $localsettings_dist
	
	  # get the database environment variables
	  getdbenv $localsettings_dist
	
	  # create a random SYSOP passsword
	  SYSOP_PASSWD=`random_password`
	 
	  # run the Mediawiki install script
	  php $mwpath/maintenance/install.php \
	    --dbname $dbname \
	    --dbpass $dbpass \
	    --dbserver $dbserver \
	    --dbtype mysql \
	    --dbuser $dbuser \
	    --email mediawiki@localhost \
	    --installdbpass $dbpass \
	    --installdbuser $dbuser \
	    --pass $SYSOP_PASSWD \
	    --scriptpath /mediawiki \
	    Sysop
	
	  color_msg $blue "Mediawiki has been installed with a single user:" 
	  echo "select user_name from user" | dosql $localsettings_dist
  	# enable the LocalSettings
  	# move the LocalSettings.php created by the installer above to the side
	  mv $mwpath/LocalSettings.php $mwpath/LocalSettings.php.install

	  mv $mwpath/LocalSettings.php.dist $mwpath/LocalSettings.php
	  # rememver the installation state
	  installed="true"
	fi
}

# 
# check that composer is installed
#
check_composer() {
if [ ! -f composer.phar ]
then
  # see https://getcomposer.org/doc/00-intro.md
  curl -sS https://getcomposer.org/installer | php
  #curl -O http://getcomposer.org/composer.phar
  #php composer.phar update
else
  color_msg $green "composer is already available"
fi
}

#
# Start of Docker Entrypoint
#
# start of script
# check arguments
option=""
installed=""
# get the hostname
#hostname=`hostname`
hostname=$IMAGEHOSTNAME

while test $# -gt 0
do
  case $1 in
    # -h|--help|usage|show this usage
    -h|--help) 
      usage;;
      
    -nols|--no_local_settings) 
      option="-nols";;
      
    -composer|--composer) 
      composer="true";;
      
    -smw|--smw) 
      composer="true";
      smw=true;;
      
    *) 
      params="$params $1"
  esac
  shift
done

# install mediawiki with the given options
mediawiki_install "$option"

# do we have a running mediawiki?
if [ "$installed" == "true" ]
then
  # shall we install composer?
	if [ "$composer" == "true" ]
	then
	  color_msg $blue "checking composer at $mwpath"
	  cd $mwpath
	  check_composer
	fi
	
	# shall we install Semantic Media Wiki?
	if [ "$smw" == "true" ] 
	then
	  color_msg $blue "installing semantic mediawiki Version "
	  cd $mwpath
	  # see https://semantic-mediawiki.org/wiki/Help:Installation/Using_Composer_with_MediaWiki_1.22_-_1.24
	  php composer.phar require mediawiki/semantic-media-wiki "~$SMW_VERSION"
	   # Semantic forms
    php ./composer.phar require mediawiki/semantic-forms "3.4.*"
	  php maintenance/update.php
cat << EOF >> $localsettings
	enableSemantics( "$hostname" );
EOF
	fi
	
	color_msg $blue "you can now login to MediaWiki with the url http://$hostname/mediawiki"
	color_msg $blue "    User: Sysop"
	color_msg $blue "Password: $SYSOP_PASSWD"
fi
# Execute docker run parameter 
exec $params
