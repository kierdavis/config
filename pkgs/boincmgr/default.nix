{ stdenv, docker, writeScriptBin, xauth }:

let
  dockerfileDir = ./dockerfiles;
in

writeScriptBin "boincmgr" ''
  #!${stdenv.shell}
  set -eu

  ${docker}/bin/docker build -t boincmgr ${dockerfileDir}

  XSOCK=/tmp/.X11-unix
  XAUTH=/tmp/.docker-auth
  ${xauth}/bin/xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | ${xauth}/bin/xauth -f $XAUTH nmerge -

  manager_dir=$HOME/.boincmgr
  mkdir -p $manager_dir

  ${docker}/bin/docker run \
    ''${DOCKER_FLAGS:-} \
    --net=host \
    --env DISPLAY \
    --env XAUTHORITY=$XAUTH \
    --volume $XSOCK:$XSOCK:rw \
    --volume $XAUTH:$XAUTH:ro \
    --volume $manager_dir:/root:rw \
    boincmgr \
    /usr/bin/boincmgr \
    --namehost 0.0.0.0 \
    --password "$(cat /var/lib/boinc/gui_rpc_auth.cfg)"
''
