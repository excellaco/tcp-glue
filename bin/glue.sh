#! /usr/bin/env bash
CONFIG_FILE=$HOME/.config/tcp-glue-config
COMMAND_NAME="fpg"
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
PINK=$(tput setaf 219)
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
USAGE="${GREEN}${BOLD}USAGE:${NORMAL}"
FORMATTED_COMMAND_NAME="${BOLD}${CYAN}${COMMAND_NAME}${NORMAL}"
USEFUL_FLAGS="${BOLD}USEFUL FLAGS:${NORMAL}"
ALL_REPOS=(api
           frontend-admin
           frontend-public)
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
command_color() {
  echo "${BOLD}${CYAN}${@}${NORMAL}"
}
args_color() {
  echo "${PINK}${@}${NORMAL}"
}
print_help() {
  echo "$COMMAND_NAME help:"
  echo
  echo "Any subcommand you would use with docker-compose works here too (up, down,"
  echo "start, exec, etc.), with the added benefit of not needing to be in the"
  echo "tcp-glue repo dir to run the command. Additionally, the following "
  echo "subcommands have been added for convenience:"
  echo
  echo "  build  -- runs the tcp-glue build script"
  echo "  bash   -- run bash within the named container"
  echo "  dir    -- sets the working directory (tcp-glue repo) for the fpg script"
  echo "  nuke   -- start over from scratch... removes all volumes, images, and containers"
  echo "  open   -- equivalent to 'docker-compose run' with service ports mapped"
  echo "  pull   -- pulls latest in your tcp-glue repo"
  echo "  vm     -- enter the VM running the docker daemon (might have to hit enter a few times)"
  echo "  watch  -- runs 'docker-compose ps' forever"
  echo ""
  echo "For additional information, use '$COMMAND_NAME manpage'"
}
print_fema_proto_glue_manpage() {
  build=$(command_color build)
  pull=$(command_color pull)
  bash=$(command_color bash)
  run=$(command_color run)
  open=$(command_color open)
  watch=$(command_color watch)
  dir=$(command_color dir)
  nuke=$(command_color nuke)
  vm=$(command_color vm)
cat <<- EOM
$NORMAL
$COMMAND_NAME manual:
This command to wraps the docker-compose command within the tcp-glue context.
Any valid docker-compose command can be run by this script. Additionally the
following subcommands are provided:
  $build   -- runs build.sh from the tcp-glue app
              $USAGE $FORMATTED_COMMAND_NAME $build $(args_color [apps...])
              Builds all apps, or optionally only the app(s) specified
  $bash    -- opens a bash terminal in the specified app container
              $USAGE $FORMATTED_COMMAND_NAME $bash $(args_color app)
  $dir     -- sets to working directory of the $FORMATTED_COMMAND_NAME script
              if no directory is specified, this will print the current tcp-glue directory used
              $USAGE $FORMATTED_COMMAND_NAME $dir $(args_color [tcp-glue directory])
  $nuke    -- start over from scratch... removes all volumes, images, and containers
              $USAGE $FORMATTED_COMMAND_NAME $nuke
  $open    -- equivalent to 'docker-compose run --rm --service-ports'
              $USAGE $FORMATTED_COMMAND_NAME $open $(args_color app command [args...])
              This is equivalent to $FORMATTED_COMMAND_NAME $run,
              except that it also opens the service ports specified in the docker-compose.yml file
  $pull    -- equivalent to 'git pull' in the tcp-glue directory
              $USAGE $FORMATTED_COMMAND_NAME $pull $(args_color [flags...] [remote] [remote_ref])
              Pulls from the git remote for tcp-glue
              If flags, remote, or remote_ref are passed in, they are passed directly to 'git pull'
  $vm      -- enter the VM running the docker daemon (might have to hit enter a few times)
              $USAGE $FORMATTED_COMMAND_NAME $vm
  $watch   -- runs 'docker-compose ps' in a loop forever
              $USAGE $FORMATTED_COMMAND_NAME $watch
EOM
}
set_dir() {
  DIR=$1
  if [[ -z $DIR ]]; then
    echo "Current fpg directory: $(pwd)"
  else
    echo "export FEMA_PROTO_GLUE_DIRECTORY='$DIR'" > $HOME/.config/tcp-glue-config
  fi
}

install_script() {
  SCRIPT="tcp-glue.sh"
  SYM_FPG=$HOME/bin/fpg

  if [[ ! -d $HOME/bin ]]; then
    mkdir -p "$HOME/bin"
  fi

  echo "Installing latest version of fpg script..."
  if [[ ! ( -f $SYM_FPG && -L $SYM_FPG ) ]]; then
    ln -sf "$PWD/bin/$SCRIPT" "$SYM_FPG"
  fi
  echo "Done!"
}

exit_and_build() {
  clear
  if [[ ! -z "$1" ]]; then
    echo "${BOLD}${1}${NORMAL}"
  fi
  echo "${BOLD}Rerunning build with latest tcp-glue changes...${NORMAL}"
  exec ./build.sh
}

check_need_to_build() {
  VER_PATH="$(git rev-parse --show-toplevel)/.version"
  LAST_VER_PATH="$(git rev-parse --show-toplevel)/.last-built-version"
  if [ ! -e $LAST_VER_PATH ]; then
    echo "${RED}${BOLD}Warning: cannot determine last tcp-glue build. You should probably run ${UNDERLINE}fpg build${NORMAL}"
    return
  fi
  VER_STR=$(cat "$VER_PATH")
  LAST_VER_STR=$(cat "$LAST_VER_PATH")
  VER_MAJ=$(echo $VER_STR | awk -F. '{print $1}')
  VER_MIN=$(echo $VER_STR | awk -F. '{print $2}')
  VER_PAT=$(echo $VER_STR | awk -F. '{print $3}')
  LAST_VER_MAJ=$(echo $LAST_VER_STR | awk -F. '{print $1}')
  LAST_VER_MIN=$(echo $LAST_VER_STR | awk -F. '{print $2}')
  LAST_VER_PAT=$(echo $LAST_VER_STR | awk -F. '{print $3}')
  if [ $VER_MAJ -gt $LAST_VER_MAJ ]; then
    exit_and_build "There is a major (breaking) change in the tcp-glue repo."
  elif [ $VER_MIN -gt $LAST_VER_MIN ]; then
    echo "${RED}${BOLD}Warning: your tcp-glue build is out of date. You should probably run ${UNDERLINE}fpg build${NORMAL}"
  fi
}

COMMAND=$1
if [ -f "$CONFIG_FILE" ]
then
  source "$CONFIG_FILE"
else
  echo "No configuration found; please use 'dir' command to specify your tcp-glue directory"
fi
pushd $FEMA_PROTO_GLUE_DIRECTORY > /dev/null
if [[ -z $COMMAND ]]; then
 print_help
else
  case $COMMAND in
    bash)
      check_need_to_build
      docker-compose run --rm $2 bash ${@:3}
      ;;
    build)
      ./build.sh ${@:2}
      ;;
    pull)
      git pull ${@:2}
      ;;
    watch)
      # TODO: insert stty setting for ixon ixoff chars
      while :; do
        # TODO: insert DC3
        clear;
        docker-compose ps;
        # TODO: insert DC1
        sleep 2;
      done
      ;;
    nuke)
      docker stop $(docker ps -q)
      docker rm $(docker ps -qa)
      docker volume rm $(docker volume ls -q)
      docker rmi $(docker images -q)
      ;;
    open)
      check_need_to_build
      docker-compose run --rm --service-ports $2 "${@:3}"
      ;;
    update)
      install_script
      ;;
    dir)
      set_dir $2
      ;;
    manpage)
      print_fema_proto_glue_manpage
      ;;
    help)
      print_help
      ;;
    version)
      echo -e "Docker version:\n$(docker version)\n"
      docker-compose version
      echo -e "\nfema-proto-glue version: $(cat .version)"
      ;;
    vm)
      if [[ "$platform" == 'mac' ]]; then
        exec screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
      else
        echo "${RED}No VM to enter. Only Mac runs containers in a VM. (detected '$unamestr').${NORMAL}"
        exit 1
      fi
      ;;
    *)
      check_need_to_build
      docker-compose ${@:1}
      ;;
  esac
fi
popd > /dev/null