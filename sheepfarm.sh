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
#[ -f ~/.sheepit.conf ] && . ~/.sheepit.conf --source-only ;
# . $prepDIR/sheepfarm.lib --source-only;
#### end of imports ####

###### helper functions ######

# whiptail --textbox sheepfarm.conf 12 50

function updatecores {
  corecount=$(grep -c ^processor /proc/cpuinfo)
  #defaults to maximum
  # cores=$corecount
  #set cores using range (1-maxcores)
}

function updategpu {
  #hardcoded until find another way
  gpuid="CUDA_0"
}

function getgpu {
  echo $gpuid >> sheepfarm.conf
}

function getavailableramkb {
  ramavailkb=$(grep -oP "(?<=MemAvailable:).*" /proc/meminfo | xargs | head -n1 | cut -d " " -f1)
}

function gettotalramkb {
  ramtotalkb=$(grep -oP "(?<=MemTotal:).*" /proc/meminfo | xargs | head -n1 | cut -d " " -f1)
  # ramtotalkb=$(vmstat -s | awk '{ print $1 }')
}

function updatecomputemethod {
  computemethod=$(whiptail --title "CPU GPU Selection" --radiolist "Choose an option" 10 50 3 \
  "CPU"  "CPU" ON \
  "GPU"  "GPU" OFF \
  "CPU_GPU"  "CPU+GPU" OFF \
  3>&1 1>&2 2>&3)

  # case $computemethod in
  #   CPU) updatecores ;;
  #   GPU) updategpu  ;;
  #   CPU_GPU) updatecores && updategpu;;
  #   *) echo "exited before selecting compute method."
  # esac
}

function updateuimethod {
  ui=$(whiptail --title "SheepIt UI Selection" --radiolist "Choose an option" 10 50 3 \
  "text"  "cli text" ON \
  "swing"  "graphical ui" OFF \
  "oneLine"  "cli one line" OFF \
  3>&1 1>&2 2>&3)
}

function updatesheepituser {
  # sheepituser=$(whiptail --inputbox "Enter your sheepit username" 8 78 user --title "Client Login User" \
  sheepituser=$(whiptail --inputbox "Enter your sheepit username" 8 78 howkj1 --title "Client Login User" \
  3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered " $sheepituser
    echo "$sheepituser" >> sheepfarm.conf ;
    echo "updating sheepfarm.conf";
    # echo "(Exit status was $exitstatus)"
  else
    echo "User selected Cancel."
  fi
}

function updatesheepitkey {
  # sheepitkey=$(whiptail --inputbox "Enter your sheepit key" 8 78 key --title "Client Login Key" \
  sheepitkey=$(whiptail --inputbox "Enter your sheepit key" 8 78 wFUBdMExz9nxtuJOsjWjQnsAc0aHngJpimqNqJCI --title "Client Login Key" \
  3>&1 1>&2 2>&3)
  exitstatus=$?
  # if [ $exitstatus = 0 ]; then
  #   echo "User selected Ok and entered " $sheepitkey
  #   echo "$sheepitkey" >> sheepfarm.conf ;
  #   echo "updating sheepfarm.conf";
  # else
  #   echo "User selected Cancel."
  # fi
}

function updatesheepitconf {
  # update ~/.sheepit.conf
  updatecores;
  updategpu;
  getgpu;
  gettotalramkb;
  updatecomputemethod;
  updateuimethod;
  updatesheepituser;
  updatesheepitkey;

  # sheepituser="howkj1";
  # sheepitkey="wFUBdMExz9nxtuJOsjWjQnsAc0aHngJpimqNqJCI";
##############
    #set date
    echo "#"`date` > sheepfarm.conf;
    #cores
    echo "cores="$corecount >> sheepfarm.conf
    #auto-signin
    echo "auto-signin=false" >> sheepfarm.conf
    #ram
    echo "ram="$ramtotalkb"k" >> sheepfarm.conf
    #compute-method
      #CPU CPU_GPU GPU
    echo "compute-method="$computemethod >> sheepfarm.conf
    #proxy
    echo "proxy=" >> sheepfarm.conf
    #ui
      #(swing,text,oneLine)
    echo "ui="$ui >> sheepfarm.conf
    #hostname
    echo "hostname="`hostname` >> sheepfarm.conf
    #compute-gpu
    echo "compute-gpu="$gpuid >> sheepfarm.conf
    #login
    echo "login="$sheepituser >> sheepfarm.conf
    #priority
      #1-19... default 19
    echo "priority=""19" >> sheepfarm.conf
    #password
    echo "password="$sheepitkey >> sheepfarm.conf
##############

    # java -jar ./sheepit-latest.jar -ui text -login bla -password blablabla -compute-method GPU -gpu CUDA_0

whiptail --textbox sheepfarm.conf 20 70
  # whiptail --title "Update Client Login" --yesno "sheepfarm.conf has been updated. \n\n username: $sheepituser \n and key: $sheepitkey" --yes-button "Continue" --no-button "quit" 10 62;
} ####### end of updatesheepitconf()

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
  IFS="=" read sheepituser <&6
  IFS="=" read sheepitkey <&6
  exec 6<&-
  echo " read user as $sheepituser from sheepfarm.conf "
  echo " read key as $sheepitkey from sheepfarm.conf "
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

###### routines ######

function sheep_prep {
  # sudo apt update;
  installGit;
  gitstuffdir;
  move_sheepfarm_to_gitstuff;
  install_openssh;
  ssh_keygen;
  install_javajre;
  update_sheepit;
  install_tmux;
  echo "sheep_prep has completed!";
}

function farm_sheep {
  ### autofire render agent ###
  # cd ~/;
  # mkdir ~/old-sheepit;
  # mv ~/sheepit-client* ~/old-sheepit/;
  update_sheepit;
  # updatesheepitconf;
  [ -f ./sheepfarm.conf ] && readsheepfarmconf;
  [ ! -f "./sheepfarm.conf" ] && updatesheepitconf;
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
  "2." "Configure client -->" \
  "3." "Download Latest SheepIt -->" \
  "4." "Build Rendering Machine -->" \
  "5." "Quit" \
  3>&1 1>&2 2>&3)

  # Below you can enter the corresponding commands
  case $RETVAL in
      # a) echo "custom menu goes here"; whiptail --title "cutom menu" --msgbox "goes here" 10 50;;
      1.) farm_sheep;;
      2.) updatesheepitconf;;
      3.) update_sheepit;;
      4.) sheep_prep;;
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



##############################################################################
## official sheepit client help ##
# Usage:
#  --no-gpu                               : Don't detect GPUs
#  --no-systray                           : Don't use systray
#  --show-gpu                             : Print available CUDA devices and exit
#  --verbose                              : Display log
#  --version                              : Display application version
#  -cache-dir /tmp/cache                  : Cache/Working directory. Caution,
#                                           everything in it not related to the
#                                           render-farm will be removed
#  -compute-method CPU                    : CPU: only use cpu, GPU: only use gpu,
#                                           CPU_GPU: can use cpu and gpu (not at
#                                           the same time) if -gpu is not use it
#                                           will not use the gpu
#  -config VAL                            : Specify the configuration file
#  -cores 3                               : Number of cores/threads to use for
#                                           the render
#  -extras VAL                            : Extras data push on the authentication
#                                           request
#  -gpu CUDA_0                            : Name of the GPU used for the render,
#                                           for example CUDA_0 for Nvidia or
#                                           OPENCL_0 for AMD/Intel card
#  -login LOGIN                           : User's login
#  -memory VAL                            : Maximum memory allow to be used by
#                                           renderer, number with unit (800M, 2G,
#                                           ...)
#  -password PASSWORD                     : User's password
#  -priority N                            : Set render process priority (19
#                                           lowest to -19 highest)
#  -proxy http://login:password@host:port : URL of the proxy
#  -rendertime N                          : Maximum time allow for each frame (in
#                                           minute)
#  -request-time 2:00-8:30,17:00-23:00    : H1:M1-H2:M2,H3:M3-H4:M4 Use the 24h
#                                           format. For example to request job
#                                           between 2am-8.30am and 5pm-11pm you
#                                           should do --request-time 2:00-8:30,17:
#                                           00-23:00 Caution, it's the requesting
#                                           job time to get a project not the
#                                           working time
#  -server URL                            : Render-farm server, default https://cl
#                                           ient.sheepit-renderfarm.com
#  -title VAL                             : Custom title for the GUI Client
#  -ui VAL                                : Specify the user interface to use,
#                                           default 'swing', available 'oneLine',
#                                           'text', 'swing' (graphical)
##############################################################################
