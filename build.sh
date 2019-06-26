#!/usr/bin/env bash
set -e

NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
PINK=$(tput setaf 219)
UNDERLINE=$(tput smul)

NUM_ARGS=$#

BASHFUL_VERSION="0.0.11"

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='mac'
else
  echo "${RED}Only Linux and Mac platforms are supported (detected '$unamestr').${NORMAL}"
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  echo "${RED}Don't run this script as root.${NORMAL}"
  exit 1
fi

if [[ "$(basename $PWD)" != "tcp-glue" ]]; then
  echo "${RED}You must run this script *explicitly* from the tcp-glue repo directory.${NORMAL}"
  exit 1
fi

function show_error_on_exit {
  echo "${RED}${BOLD}Step failed! Exiting...${NORMAL}"
  set +e
  if [[ $(docker-compose ps | wc -l | awk '{print $1}') > 2 ]] ; then
    docker-compose down
  fi
}

function download_bashful {
  if [[ ! -d downloads/bashful ]]; then
    mkdir -p downloads/bashful
  fi

  pushd downloads/bashful > /dev/null
    if [[ ! -e $LINUX_BASHFUL_FILE ]]; then
      wget $LINUX_BASHFUL_URL
    fi
  popd > /dev/null
}

trap show_error_on_exit EXIT

set +e

# Pull the latest version of this repo and rerun this script if there are no changes/commits
BRANCH=$(git symbolic-ref --short HEAD)
HAS_CHANGES=$(git status -s)
if [[ "$BRANCH" == "master" && -z $HAS_CHANGES ]]; then
  echo "${CYAN}Pulling latest tcp-glue changes${NORMAL}"

  git fetch

  UPSTREAM=${1:-'@{u}'}
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "$UPSTREAM")
  BASE=$(git merge-base @ "$UPSTREAM")

  if [ $LOCAL = $REMOTE ]; then
      echo "${GREEN}tcp-glue git status: Already Up-to-date${NORMAL}"
  elif [ $LOCAL = $BASE ]; then
      echo "${YELLOW}tcp-glue git status: Pulling latest${NORMAL}"
      git pull origin master
      if [ $? -eq 0 ]; then
        clear
        echo "${BOLD}Rerunning build with latest tcp-glue changes...${NORMAL}"
        exec ./build.sh
      else
        echo "${RED}${BOLD}Could not pull the latest tcp-glue changes!${NORMAL}"
      fi
  elif [ $REMOTE = $BASE ]; then
      echo "${YELLOW}tcp-glue git status: Need to push (Will not pull latest)${NORMAL}"
  else
      echo "${YELLOW}tcp-glue git status: Branch diverged (Will not pull latest)${NORMAL}"
  fi
else
  echo "${YELLOW}tcp-glue git status: Detected pending changes (Will not pull latest)${NORMAL}"
fi

LINUX_BASHFUL_FILE="bashful_${BASHFUL_VERSION}_linux_amd64.deb"
LINUX_BASHFUL_URL="https://github.com/wagoodman/bashful/releases/download/v0.0.11/$LINUX_BASHFUL_FILE"

which bashful &> /dev/null

if [[ $? -ne 0 ]]; then
  if [[ "$platform" == 'mac' ]]; then
    brew tap wagoodman/bashful
    brew install bashful
  else
    download_bashful

    echo "${RED}${BOLD}Please install bashful from root of tcp-glue with:${NORMAL}"
    echo "${RED}${BOLD}sudo apt install ./downloads/bashful/bashful_0.0.11_linux_amd64.deb${NORMAL}"
    exit 1
  fi
else
  bashful --version | grep $BASHFUL_VERSION > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    if [[ "$platform" == 'mac' ]]; then
      brew upgrade bashful
    else
      download_bashful

      echo "${RED}${BOLD}Please update bashful from root of tcp-glue with:${NORMAL}"
      echo "${RED}${BOLD}sudo apt install ./downloads/bashful/bashful_0.0.11_linux_amd64.deb${NORMAL}"
      exit 1
    fi
  fi
fi

cat /dev/null > build.log
set -e

if [ "$#" -gt 0 ]; then
  bashful run bin/build.yml --tags $@
else
  bashful run bin/build.yml
fi
set +e

echo "${GREEN}${BOLD}Build completed successfully!${NORMAL}"

cp .version .last-built-version

# graceful exit
trap - EXIT