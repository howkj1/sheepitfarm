#!/bin/bash
# sheepfarm is a guided automation script for
# deploying sheepit-renderfarm.com render node clients
# git clone https://github.com/howkj1/sheepfarm.git
# https://en.wikibooks.org/wiki/Bash_Shell_Scripting/Whiptail
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

prepDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

function updatecores {
  corecount=$(grep -c ^processor /proc/cpuinfo)
}

function updategpu {
  gpuid=$(java -jar ./sheepit-latest.jar --show-gpu |  head -n1 | cut -d ":" -f2- | sed -e 's/^[ \t]*//' | sed "s/:/\\\:/g")
}

function getgpu {
  echo $gpuid >> ~/.sheepit.conf
}

function getavailableramkb {
  ramavailkb=$(grep -oP "(?<=MemAvailable:).*" /proc/meminfo | xargs | head -n1 | cut -d " " -f1)
}

function gettotalramkb {
  ramtotalkb=$(grep -oP "(?<=MemTotal:).*" /proc/meminfo | xargs | head -n1 | cut -d " " -f1)
}

function updatecomputemethod {
  computemethod=$(whiptail --title "CPU GPU Selection" --radiolist "Choose an option" 10 50 3 \
  "CPU"  "CPU" ON \
  "GPU"  "GPU" OFF \
  "CPU_GPU"  "CPU+GPU" OFF \
  3>&1 1>&2 2>&3)
}

function updateuimethod {
  ui=$(whiptail --title "SheepIt UI Selection" --radiolist "Choose an option" 10 50 3 \
  "text"  "cli text" ON \
  "swing"  "graphical ui" OFF \
  "oneLine"  "cli one line" OFF \
  3>&1 1>&2 2>&3)
}

function updatesheepituser {
  sheepituser=$(whiptail --inputbox "Enter your sheepit username" 8 78 howkj1 --title "Client Login User" \
  3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo "$sheepituser" >> ~/.sheepit.conf ;
  else
    echo "User selected Cancel."
  fi
}

function updatesheepitkey {
  sheepitkey=$(whiptail --inputbox "Enter your sheepit key" 8 78 wFUBdMExz9nxtuJOsjWjQnsAc0aHngJpimqNqJCI --title "Client Login Key" \
  3>&1 1>&2 2>&3)
  exitstatus=$?
}

function updatesheepitconf {
  if (whiptail --title "Disclaimer" --yesno "Your ~/.sheepit.conf will be over-written if you continue. \n\n                 " --yes-button "Generate" --no-button "Cancel" 10 62)
  then
  updatecores;
  updategpu;
  getgpu;
  gettotalramkb;
  updatecomputemethod;
  updateuimethod;
  updatesheepituser;
  updatesheepitkey;
    echo "#"`date` > ~/.sheepit.conf;
    echo "cores="$corecount >> ~/.sheepit.conf
    echo "auto-signin=false" >> ~/.sheepit.conf
    echo "ram="$ramtotalkb"k" >> ~/.sheepit.conf
    echo "compute-method="$computemethod >> ~/.sheepit.conf
    echo "proxy=" >> ~/.sheepit.conf
    echo "ui="$ui >> ~/.sheepit.conf
    echo "hostname="`hostname` >> ~/.sheepit.conf
    echo "compute-gpu="$gpuid >> ~/.sheepit.conf
    echo "login="$sheepituser >> ~/.sheepit.conf
    echo "priority=""19" >> ~/.sheepit.conf
    echo "password="$sheepitkey >> ~/.sheepit.conf
    whiptail --title "~/.sheepit.conf" --textbox ~/.sheepit.conf 20 70
    main_sheep_menu;
  else
      main_sheep_menu;
  fi;
}

function installGit {
  clear;
  echo;echo "checking for updates... ";
  sudo apt-get -qq update > /dev/null  2>&1; wait;
  echo -ne "...                                 \r";
  echo -ne "installing git... \r";
  sudo apt-get -qq -y install git; wait;
  echo -ne "git installed!      \r";
}

function gitstuffdir {
  echo -ne "...                                 \r";
  echo -ne "making gitstuff folder... \r";sleep 1;
  [ ! -d ~/gitstuff ] && mkdir ~/gitstuff;
  echo -ne "opening gitstuff folder... \r"; sleep 1;
  cd ~/gitstuff;
}

function move_sheepfarm_to_gitstuff {
  echo "creating local repo in ~/gitstuff/sheepfarm/";
  gitstuffdir;
  [ ! -d ~/gitstuff/sheepfarm ] && cd ~/gitstuff && git clone https://github.com/howkj1/sheepfarm.git;
}

function install_openssh {
  sudo apt-get -qq -y install openssh-server ;
}

function ssh_keygen {
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
}

function install_tmux {
  snap install tmux;
}

function readsheepfarmconf {
  [ -f ~/.sheepit.conf ] && echo "" && printf "%s\n" ~/.sheepit.conf && cat ~/.sheepit.conf && echo "";
  [ ! -f ~/.sheepit.conf ] && echo "---no config file found---";
}

function update_sheepit {
  echo "";
  echo -en "downloading latest sheepit render client\r";
  wget --no-check-certificate https://sheepit-renderfarm.com/media/applet/client-latest.php -O sheepit-latest.jar
  echo "latest sheepit client installed.                    ";
  whiptail --msgbox "latest sheepit client installed." 10 70;
  main_sheep_menu;
}

function update_sheepit_silent {
  echo "";
  echo -en "downloading latest sheepit render client\r";
  wget --no-check-certificate https://sheepit-renderfarm.com/media/applet/client-latest.php -O sheepit-latest.jar
  echo "latest sheepit client installed.                    ";
}

function sheep_prep {
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
  [ -f ~/.sheepit.conf ] && readsheepfarmconf;
  [ ! -f ~/.sheepit.conf ] && updatesheepitconf;
  update_sheepit_silent;
  SHEEPIT="$(printf "%s\n" sheepit-latest.jar)";
  echo "I Am The Machine! Baaa!";
  echo "now running: "
  echo "java -jar $SHEEPIT -config ~/.sheepit.conf;"
  java -jar $SHEEPIT -config ~/.sheepit.conf;
}

function main_sheep_menu {
  RETVAL=$(whiptail --title "Make a selection and Enter" \
  --menu "Main Menu" 12 50 4 \
  "1." "Run the latest SheepIt -->" \
  "2." "Configure client -->" \
  "3." "Download Latest SheepIt -->" \
  "4." "Build Rendering Machine -->" \
  "5." "Quit" \
  3>&1 1>&2 2>&3)
  case $RETVAL in
      1.) farm_sheep;;
      2.) updatesheepitconf;;
      3.) update_sheepit;;
      4.) sheep_prep;;
      5.) echo "You have quit sheepfarm.";;
      *) echo "sheepfarm has quit.";
  esac
}

if (whiptail --title "Disclaimer" --yesno "This utility script comes without warranty nor liability. \n\n                 Use at your own risk." --yes-button "Continue" --no-button "quit" 10 62)
then
  main_sheep_menu;
else
  echo "You have quit sheepfarm." # quits right away
fi;
#########################
