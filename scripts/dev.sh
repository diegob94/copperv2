#!/bin/bash

MOUNT_DIR=$(readlink -f ${MOUNT_DIR:-${PWD}})

WORK_DIR_OPT=""
if [[ "${WORK_DIR}" != "" ]]; then
    WORK_DIR_OPT="--workdir $WORK_DIR"
fi

IVY2_DIR=$MOUNT_DIR/work/.ivy2
SBT_DIR=$MOUNT_DIR/work/.sbt
CACHE_DIR=$MOUNT_DIR/work/.cache
mkdir -p $IVY2_DIR
mkdir -p $SBT_DIR
mkdir -p $CACHE_DIR

podman run --rm -it -v ${MOUNT_DIR}:/container:Z -v ${IVY2_DIR}:/root/.ivy2:Z -v ${SBT_DIR}:/root/.sbt:Z -v ${CACHE_DIR}:/root/.cache:Z $WORK_DIR_OPT diegob94/open_eda:copperv2_dev "$@"

