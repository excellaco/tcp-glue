#!/usr/bin/env bash
set -x

REPO=$1
API_FILES=(build.gradle)
NORMAL=$(tput sgr0)
CYAN=$(tput setaf 6)
RED=$(tput setaf 1)
BOLD=$(tput bold)

copy_files() {
  FILES=$1
  for FILE in ${FILES[@]}; do
    if [[ ! -f ../tcp-$REPO/$FILE ]]; then
      >&2 echo "$FILE not found at tcp-$REPO/$FILE"
      pushd ../tcp-$REPO > /dev/null
        git fetch origin master &> /dev/null
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        MASTER_CHANGE_COUNT=$(git rev-list master...origin/master --count)
      popd > /dev/null
      if [[ "$BRANCH" != "master" ]]; then
        >&2 echo "${YELLOW}Not on master branch in tcp-$REPO, try switching to master branch${NORMAL}"
      fi
      if [[ $MASTER_CHANGE_COUNT -ne 0 ]]; then
        >&2 echo "${YELLOW}master branch of tcp-$REPO different than origin/master, try pulling latest from master${NORMAL}"
      fi
      exit 1
    fi
    echo "${CYAN}Copying ../tcp-$REPO/$FILE to build-assets/$REPO/$FILE${NORMAL}"
    cp ../tcp-$REPO/$FILE build-assets/$REPO/$FILE
  done
}

# if [[ -d build-assets/tcp-$REPO ]]; then
#   rm -r build-assets/tcp-$REPO
# fi

# if [[ -d ../tcp-$REPO ]]; then
#   mkdir -p build-assets/$REPO
# fi

# case $REPO in
#   api)
#     copy_files $API_FILES
#     ;;

#   frontend-admin)
#     ;;

#   frontend-public)
#     ;;

#   *)
#     echo "${RED}${BOLD}tcp-$REPO is not a valid application${NORMAL}"
#     exit 1
# esac

