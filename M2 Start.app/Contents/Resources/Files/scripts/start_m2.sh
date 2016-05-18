#!/bin/sh

##
# Main startup script for Magento 2 docker container
##

RED_TEXT=`echo "\033[31m"`
RESET='\033[00;00m'
NORMAL=`echo "\033[m"`

check_required_installed(){
   
   if [ ! $(which docker-osx-dev) ]; then
      echo "! ${RED_TEXT}Please install docker-osx-dev and make sure is in \$PATH before proceeding${NORMAL} (see README)"
      exit;
   fi
}

copy_volume_from_container(){

   if [ ! -d "../volumes/var/www/magento2" ]; then
      echo "* Magento2 installation not found in local volumes...building container and synching filesystem"
      echo "* I would take a break or do whatever you do...this will take several minutes"
      ## Start Container without vol and copy
      cd Contents/Resources/Files/docker
      docker-compose build
      docker-compose --file docker-compose-without-volumes.yml up -d
      echo " "
      printf 'Starting initial load of containers'
      until $(curl --output /dev/null --silent --head --fail http://docker.localhost.com); do
         printf '.'
         sleep 2
      done
      echo " "
      echo "Linking to container files to local filesystem"
      docker cp docker_magento2_1:/var/www/magento2 ../../../../../volumes/var/www/magento2
      docker cp docker_mysql_1:/var/lib/mysql ../../../../../volumes/var/lib/mysql
      docker-osx-dev install
      docker-osx-dev sync-only -r
      docker-compose stop
      cd ../../../../
   fi
}

# Check for volumes
if [ ! -d "../volumes/var/www/magento2" ]; then
   mkdir -p ../volumes/var/www/
fi
if [ ! -d "../volumes/var/lib/mysql" ]; then
   mkdir -p ../volumes/var/lib/
fi

check_required_installed
copy_volume_from_container

# Docker compose up
cd Contents/Resources/Files/docker
pkill -f docker-osx-dev
docker-osx-dev watch-only -r & 
sleep 2
docker-compose up -d

echo " "
printf 'Starting Magento2 development environment'
until $(curl --output /dev/null --silent --head --fail http://docker.localhost.com); do
    printf '.'
    sleep 3
done

# Open browser
open http://docker.localhost.com

show_menu(){
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo "${MENU}******************************************************************************${NORMAL}"
    echo "${MENU}** Magento2 Development Environment Manager${NORMAL}"
    echo "${MENU}** ${NORMAL}"
    echo "${MENU}**${NUMBER} 1)${MENU} Stop M2 ${NORMAL}"
    echo "${MENU}**${NUMBER} 2)${MENU} Restart M2 ${NORMAL}"
    echo "${MENU}******************************************************************************${NORMAL}"
    echo " "
    echo "${ENTER_LINE}Please enter a menu option and hit return${NORMAL}"
    read opt
}
function option_picked() {
    COLOR='\033[01;31m' # bold red
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo "${COLOR}${MESSAGE}${RESET}"
}

clear
show_menu
while [ opt != '' ]
    do
    if [[ $opt = "" ]]; then
      clear;
      show_menu
    else
        case $opt in
        1) clear;
        option_picked "Stopping M2";
        docker-compose stop
        pkill -f docker-osx-dev
        cd ../../../../../
        exit;
        ;;
        2) clear;
        option_picked "Restarting M2";
        docker-compose restart
        clear;
        show_menu
        ;;
        x) clear; 
        docker-compose stop
        cd ../../../../../
        exit;
        ;;
        *) clear;
        option_picked "Pick an option from the menu";
        show_menu;
        ;;
    esac
fi
done
