#!/bin/bash
CONTAINER_ID=""
CONTAINER_NAME=""

ntr_arr=( $(echo $(cat /etc/nv_tegra_release) | tr -s ',' ' ') )
MAJOR_VERSION=${ntr_arr[1]}
MINOR_VERSION=${ntr_arr[4]}

PROG_NAME=$(basename $0)

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help                      Show this help
    -i, --id                        Specify the container ID
    -n, --name NAME                 Specify the name of the container
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--id" ]] || [[ $1 == "-i" ]]; then
        if [[ $2 == -* ]]; then
            echo "Invalid parameter"
            usage_exit
        else
            CONTAINER_ID=$2
        fi
        shift 2
    elif [[ $1 == "--name" ]] || [[ $1 == "-n" ]]; then
        if [[ $2 == -* ]] || [[ $2 == *- ]]; then
            echo "Invalid parameter： $1 $2"
            usage_exit
        fi
        CONTAINER_NAME=$2
        shift 2
    else
        echo "Invalid parameter： $1"
        usage_exit
    fi
done

if [[ -n ${CONTAINER_ID} ]]; then
    CONTAINER_ID=$(docker ps | grep ${CONTAINER_ID})
else
    CONTAINER_ID=$(docker ps | grep "jetson/ros:${MAJOR_VERSION,,}.${MINOR_VERSION}-melodic")

    if [[ -n ${CONTAINER_NAME} ]]; then
        CONTAINER_ID=$(echo "${CONTAINER_ID}" | grep ${CONTAINER_NAME})
    fi
fi

CONTAINER_NUMS=$(echo "${CONTAINER_ID}" | wc -l)

if [[ ${CONTAINER_NUMS} -eq 0 ]]; then
    echo "The running ROS-Bridge container does not exist．"
    usage_exit
elif [[ ${CONTAINER_NUMS} -ne 1 ]]; then
    echo "There are multiple ROS-Bridge containers running．"
    echo ""
    docker ps
    echo ""
    echo "Please add an option．"
    usage_exit
fi

CONTAINER_ID=${CONTAINER_ID:0:12}

docker exec -it ${CONTAINER_ID} /bin/bash
