#!/usr/bin/env bash
set -eu

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)


# TODO: move to common utils area

function major_minor_patch_version_compare () {
  set +u
  if [[ $1 == $2 ]]
  then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
  do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++))
  do
    if [[ -z ${ver2[i]} ]]
    then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]}))
    then
      set -u
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]}))
    then
      set -u
      return 2
    fi
  done
  set -u
  return 0
}

is_valid_version () {
  if [[ -z $1 || -z $2 || -z $3 ]]; then
    return 1
  fi
  major_minor_patch_version_compare $1 $2
  case $? in
    0) op='=';;
    1) op='>';;
    2) op='<';;
  esac
  if [[ $op != $3 ]]; then
    echo "${RED}Unsupported Version: $1 (requirement: $3 $2)${NORMAL}"
    return 1
  else
    return 0
  fi
}

DOCKER_VERSION="$(docker version --format '{{.Server.Version}}' |  awk -F'-' '{print $1}')"
set +e
is_valid_version "$DOCKER_VERSION" "17.06" ">"
if [[ $? -ne 0 ]]; then
  echo "${RED}Please upgrade docker${NORMAL}"
  exit 1
fi

set -e

set +e
DOCKER_COMPOSE_VERSION="$(docker-compose version --short)"
is_valid_version "$DOCKER_COMPOSE_VERSION" "1.19.0" ">"
if [[ $? -ne 0 ]]; then
  echo "${BOLD}Downloading docker-compose${NORMAL}"
  curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi
set -e