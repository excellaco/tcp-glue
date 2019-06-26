#!/usr/bin/env bash
#set -eu
set -x

REPO_PREFIX=tcp
REPO=$1
NORMAL=$(tput sgr0)
CYAN=$(tput setaf 6)

echo "TARGET: $REPO_PREFIX-$REPO"

if [[ ! -d ../$REPO_PREFIX-$REPO ]]; then
  echo "${CYAN}Cloning ${REPO}${NORMAL}"
  pushd ../ > /dev/null
    git clone git@github.com:excellaco/$REPO_PREFIX-$REPO.git
  popd > /dev/null

  # we will be mounting this file so we should ensure it exists
  touch ~/.gitconfig
fi