# docker build -t $USER/jwm --build-arg DOCKER_UID=$(id -u) .

function jwm() {
  docker info &> /dev/null \
    || { echo 'Is the docker daemon running?' && return 1 ;}

  [[ -e /tmp/.X11-unix/X1 ]] \
    && local exists='true' \
    || Xephyr -wr -resizeable :1 &> /dev/null &

  docker run $@ \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "/run/user/${UID}/pulse/native:/tmp/pulse/native" \
    -v "${HOME}/.config/pulse/cookie:/tmp/pulse/cookie" \
    -it --rm "${USER}/jwm" &> /dev/null

  [[ -z ${exists} ]] && pkill Xephyr &> /dev/null
}
