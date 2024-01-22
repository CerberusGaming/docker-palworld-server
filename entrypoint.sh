#!/usr/bin/env bash


# Variables
USER=${USER:="$(whoami)"}
PALWORLD_PATH=${PALWORLD_PATH:="/palworld"}
UPDATE_ON_START=${UPDATE_ON_START:="false"}

# Helpers
function update_server() {
  echo "Server Updating..."
  chown -R "$USER":"$USER" "$PALWORLD_PATH"
  su "${USER}" -c "/home/steam/steamcmd/steamcmd.sh +force_install_dir $PALWORLD_PATH +login anonymous +app_update 2394010 validate +quit"
  su "${USER}" -c "mkdir -p $PALWORLD_PATH/Pal/Saved/Config/LinuxServer"
}

function configure_server(){
  CONFIG_PATH="$PALWORLD_PATH/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"
  echo "Server Configuring..."
  echo " > Config Path: $CONFIG_PATH"

  BASE_CONFIG=${BASE_CONFIG:="$PALWORLD_PATH/DefaultPalWorldSettings.ini"}
  CONFIGDATA=$(cat $BASE_CONFIG | grep -o '^[^;]*' | sed '/^\s*$/d' || echo '')

  CONFIGDATA=$(echo -n "$CONFIGDATA" | sed -r 's/,/,\n/g')
  for config in $(printenv | grep 'CFG_'); do
    config=${config/CFG_}

    cvar=$(echo "$config" | cut -d '=' -f 1)
    cval=$(echo "$config" | cut -d '=' -f 2)

    quote=$(echo "$CONFIGDATA" | grep "$cvar" | cut -d '=' -f 2 | cut -c1-1)
    if [ "$quote" = "'" ] || [ "$quote" = '"' ]; then
        cval="$quote$cval$quote"
    fi

    CONFIGDATA=$(echo -n "$CONFIGDATA" | sed -r "s/$cvar=.*/$cvar=$cval,/g")
  done;

  su "${USER}" -c "echo -n '$CONFIGDATA' | tr -d '\n' > $CONFIG_PATH"
}

function execute_server() {
  echo "Server Starting..."

  START_OPTIONS=""
  if [[ -n $COMMUNITY_SERVER ]] && [[ $COMMUNITY_SERVER == "true" ]]; then
    START_OPTIONS="$START_OPTIONS EpicApp=PalServer"
  fi

  CORES="$(( $(lscpu | awk '/^Socket\(s\)/{ print $2 }') * $(lscpu | awk '/^Core\(s\) per socket/{ print $4 }') ))"
  if [[ -n $MULTITHREAD_SERVER ]] && [[ "$CORES" -gt "1" ]] || [[ $MULTITHREAD_SERVER == "true" ]]; then
    START_OPTIONS="$START_OPTIONS -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
  fi

  START_OPTIONS="$START_OPTIONS $*"

  pushd "$PALWORLD_PATH" > /dev/null || exit 1
    su "${USER}" -c "./PalServer.sh $START_OPTIONS"
  popd > /dev/null || exit 1
}


# Run
if [ $UPDATE_ON_START == "true" ] || [ ! -f "$PALWORLD_PATH/PalServer.sh" ]; then
  update_server
fi

configure_server

term_handler() {
	kill -SIGTERM $(pidof PalServer-Linux-Test)
	tail --pid=$(pidof PalServer-Linux-Test) -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM

execute_server "$@" &
killpid="$!"
while true
do
  wait $killpid
  exit 0;
done