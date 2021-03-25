#!/bin/bash
ntr_arr=( $(echo $(cat /etc/nv_tegra_release) | tr -s ',' ' ') )
MAJOR_VERSION=${ntr_arr[1]}
MINOR_VERSION=${ntr_arr[4]}

CONTAINER_NAME="ros-master"
DOCKER_IMAGE="jetson/ros:${MAJOR_VERSION,,}.${MINOR_VERSION}-melodic"
CONTAINER_CMD=""
DOCKER_ENV=""

USER_ID=$(id -u)
PROG_NAME=$(basename $0)

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help              Show this help
    -n, --name NAME         Specify the name of the container（Default value：${CONTAINER_NAME}）
    -e, --env ENV=VALUE     Specify the environment variable of the container (multiple can be specified)
    -c, --command CMD       Specify the command to be executed when the container starts
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--name" ]] || [[ $1 == "-n" ]]; then
        if [[ $2 == -* ]] || [[ $2 == *- ]]; then
            echo "Invalid parameter： $1 $2"
            usage_exit
        fi
        CONTAINER_NAME=$2
        shift 2
    elif [[ $1 == "--env" ]] || [[ $1 == "-e" ]]; then
        if [[ $2 == -* ]] || [[ $2 == *- ]]; then
            echo "Invalid parameter： $1 $2"
            usage_exit
        fi
        DOCKER_ENV="${DOCKER_ENV} -e $2"
        shift 2
    elif [[ $1 == "--command" ]] || [[ $1 == "-c" ]]; then
        if [[ $2 == -* ]] || [[ $2 == *- ]]; then
            echo "Invalid parameter"
            usage_exit
        fi
        CONTAINER_CMD=$2
        shift 2
    else
        echo "Invalid parameter： $1"
        usage_exit
    fi
done

ASOCK="/tmp/pulseaudio.socket"
ACKIE="/tmp/pulseaudio.cookie"
ACONF="/tmp/pulseaudio.client.conf"

HOST_WS=$(dirname $(dirname $(readlink -f $0)))/catkin_ws

DOCKER_VOLUME="${DOCKER_VOLUME} -v ${HOST_WS}:/home/ros/catkin_ws:rw"
DOCKER_VOLUME="${DOCKER_VOLUME} -v ${ASOCK}:${ASOCK}"
DOCKER_VOLUME="${DOCKER_VOLUME} -v ${ACONF}:/etc/pulse/client.conf"

DOCKER_ENV="-e USER_ID=${USER_ID}"
DOCKER_ENV="${DOCKER_ENV} -e TERM=xterm-256color"
DOCKER_ENV="${DOCKER_ENV} -e PULSE_SERVER=unix:/tmp/pulseaudio.socket"
DOCKER_ENV="${DOCKER_ENV} -e PULSE_COOKIE=${ACKIE}"

DOCKER_NET="host"

if [[ ! -S /tmp/pulseaudio.socket ]]; then
    pacmd load-module module-native-protocol-unix socket=${ASOCK}
fi

if [[ ! -f ${ACONF} ]]; then
    touch ${ACONF}
    echo "default-server = unix:/tmp/pulseaudio.socket" > ${ACONF}
    echo "autospawn = no" > ${ACONF}
    echo "daemon-binary = /bin/true" > ${ACONF}
    echo "enable-shm = false" > ${ACONF}
fi

docker run --rm -it --gpus all --privileged --name ${CONTAINER_NAME} --net ${DOCKER_NET} ${DOCKER_ENV} ${DOCKER_VOLUME} ${DOCKER_IMAGE} ${CONTAINER_CMD}
