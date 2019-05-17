#!/bin/bash

# sheepfarm is a guided automation script for
# deploying sheepit-renderfarm.com render node clients
#
# git clone https://github.com/howkj1/sheepfarm.git
#

## begin magical code land ##
export NEWT_COLORS='
window=,black
border=white,blue
textbox=white,black
button=white,magenta
title=black,white
label=black,white
actsellistbox=white,brown
'

####    imports    ####
prepDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

## commonfunctions.lib ##
# . $prepDIR/sheepfarm.lib --source-only;
##
#### end of imports ####

###### helper functions ######

function updatesheepituser {
  # update user credentials
  # only call updatesheepituser from a menu... do not use it in automation

  sheepituser=$(whiptail --inputbox "Enter your sheepit username" 8 78 user --title "Client Login User" \
  3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo "User selected Ok and entered " $sheepituser
      echo "$sheepituser" > sheepfarm.conf ;
            echo "updating sheepfarm.conf";
  else
      echo "User selected Cancel."
  fi
  # echo "(Exit status was $exitstatus)"
  sheepitkey=$(whiptail --inputbox "Enter your sheepit key" 8 78 key --title "Client Login Key" \
  3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo "User selected Ok and entered " $sheepitkey
      echo "$sheepitkey" >> sheepfarm.conf ;
      echo "updating sheepfarm.conf";
  else
      echo "User selected Cancel."
  fi

  if (whiptail --title "Update Client Login" --yesno "sheepfarm.conf has been updated. \n\n username: $sheepituser \n and key: $sheepitkey" --yes-button "Continue" --no-button "quit" 10 62)
  then
    main_sheep_menu;
  else
    echo "You have quit sheepfarm." # quits right away
  fi;
}

function preproutine {
  echo;
  echo -ne "starting preproutine... \r";
  echo -ne 'here we go... \r';
  sleep .5;
  echo -ne 'here we go... ... \r';
  sleep .5;
  echo -ne 'here we go... ... ... \r';
  sleep .5;
  echo -ne 'here we go... ... ... ...\r';
  echo -ne '\n';
}

function installGit {
  clear;
  ### this block installs gitclient
  # TODO until script is updated to check if git is installed
  echo;echo "checking for updates... ";
  sudo apt-get -qq update > /dev/null  2>&1; wait;
  echo -ne "...                                 \r";
  echo -ne "installing git... \r";
  sudo apt-get -qq -y install git; wait;
  echo -ne "git installed!      \r";
  ###
}

function gitstuffdir {
  echo -ne "...                                 \r";
  echo -ne "making gitstuff folder... \r";sleep 1;
  [ ! -d ~/gitstuff ] && mkdir ~/gitstuff;
  echo -ne "opening gitstuff folder... \r"; sleep 1;
  cd ~/gitstuff;
}

function move_sheepfarm_to_gitstuff {
  # moves, copies, or clones sheepfarm scripts and deps into ~/gitstuff/sheepfarm/
  echo "creating local repo in ~/gitstuff/sheepfarm/";
  gitstuffdir;
  [ ! -d ~/gitstuff/sheepfarm ] && cd ~/gitstuff && git clone https://github.com/howkj1/sheepfarm.git;
}

function install_openssh {
  # openssh server
  sudo apt-get -qq -y install openssh-server ;
}

function ssh_keygen {
  #generate ssh rsa keys
  your_email=$(whiptail --inputbox "Enter your full email address (yourname@gmail.com)" 8 78 email --title "SSH KeyGen" \
  3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
      echo "User selected Ok and entered " $your_email
      ssh-keygen -t rsa -b 4096 -C $your_email
      ssh-add ~/.ssh/id_rsa
      sudo apt-get -qq -y install xclip
      xclip -sel clip < ~/.ssh/id_rsa.pub
  else
      echo "User selected Cancel."
  fi
  # echo "(Exit status was $exitstatus)"
}

function install_tmux {
  #install tmux
  snap install tmux;
}

function readsheepfarmconf {
  #read username & key from file
  exec 6< sheepfarm.conf
  read sheepituser <&6
  read sheepitkey <&6
  exec 6<&-
  echo " read user as $sheepituser from sheepfarm.conf "
  echo " read key as $sheepitkey from sheepfarm.conf "
}

###### routines ######

function sheep_prep {

  preproutine;

  # sudo apt update;
  installGit;
  gitstuffdir;
  move_sheepfarm_to_gitstuff;
  install_openssh;
  ssh_keygen;

  install_javajre;
  install_sheepit;final

  install_tmux;

  echo "prep has completed!";
}

function update_sheepit {
  # sheepit render farm client
  echo "";
  echo -en "downloading latest sheepit render client\r";
  wget --no-check-certificate https://sheepit-renderfarm.com/media/applet/client-latest.php -O sheepit-latest.jar
  #wget -P ~/ https://www.sheepit-renderfarm.com/media/applet/sheepit-client-5.658.2896.jar;
  # wget -P ~/ https://www.sheepit-renderfarm.com/media/applet/client-latest.php;
  echo "latest sheepit client installed.                    ";
}

function farm_sheep {
  ### autofire render agent ###
  # cd ~/;
  # mkdir ~/old-sheepit;
  # mv ~/sheepit-client* ~/old-sheepit/;
  update_sheepit;
  # updatesheepituser;
  [ -f ./sheepfarm.conf ] && readsheepfarmconf;
  [ ! -f "./sheepfarm.conf" ] && updatesheepituser;
  # SHEEPIT="$(printf "%s\n" sheep* | head -1)";
  SHEEPIT="$(printf "%s\n" sheepit-latest.jar)";
  echo "I Am The Machine! Baaa!";
  echo "now running: "
  echo "java -jar $SHEEPIT -ui text -login $sheepituser -password $sheepitkey ;"
  java -jar $SHEEPIT -ui text -login $sheepituser -password $sheepitkey ;
  #######################
}

function main_sheep_menu {
  # visible menu options:
  RETVAL=$(whiptail --title "Make a selection and Enter" \
  --menu "Main Menu" 12 50 4 \
  "1." "Run the latest SheepIt -->" \
  "2." "Build Rendering Machine -->" \
  "3." "Download Latest SheepIt -->" \
  "4." "Configure client user+key -->" \
  "5." "Quit" \
  3>&1 1>&2 2>&3)

  # Below you can enter the corresponding commands
  case $RETVAL in
      # a) echo "custom menu goes here"; whiptail --title "cutom menu" --msgbox "goes here" 10 50;;
      1.) farm_sheep;;
      2.) sheep_prep;;
      3.) update_sheepit;;
      4.) updatesheepituser;;
      5.) echo "You have quit sheepfarm.";;
      *) echo "sheepfarm has quit.";
  esac
}

#### Intro Info Menu + Disclaimer ####
if (whiptail --title "Disclaimer" --yesno "This utility script comes without warranty nor liability. \n\n                 Use at your own risk." --yes-button "Continue" --no-button "quit" 10 62)
then
  main_sheep_menu;
else
  echo "You have quit sheepfarm." # quits right away
fi;
### end menu ###
#########################
