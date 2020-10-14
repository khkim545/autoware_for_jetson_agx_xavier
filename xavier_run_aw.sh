#!/bin/bash

if [ "$#" != "1" ]; then
          echo "Usage: $0 [image_tag]"
          exit 1
fi

TAG=$1
IMAGE=autoware/autoware:${TAG}
USER_ID=1000

RUNTIME="--runtime=nvidia"

echo "Launching $IMAGE"

###
### This script is based on tx2-docker script, which was introduced at 
### https://github.com/Technica-Corporation/Tegra-Docker.
### It enables a container to access GPUs of nvidia drive px2
### You can run deviceQuery to see if it accesses the GPUs
###

XSOCK=/tmp/.X11-unix
XAUTH=$HOME/.Xauthority
#LD_LIB=/usr/lib/aarch64-linux-gnu:/usr/local/cuda/lib64:/host/usr/lib/aarch64-linux-gnu:/host/usr/lib/aarch64-linux-gnu/tegra

SHARED_DOCK_DIR=/home/autoware/shared_dir
SHARED_HOST_DIR=$HOME/shared_dir
mkdir -p $SHARED_HOST_DIR

__CUDA_DOCK_DIR=/usr/local/cuda-10.0 # includes /usr/local/cuda-10.0/lib64
__CUDA_HOST_DIR=/usr/local/cuda-10.0 # includes /usr/local/cuda-10.0/lib64
__TSRT_DOCK_DIR=/usr/src/tensorrt
__TSRT_HOST_DIR=/usr/src/tensorrt
UAARCH_DOCK_DIR=/host/usr/lib/aarch64-linux-gnu
UAARCH_HOST_DIR=/usr/lib/aarch64-linux-gnu
LAARCH_DOCK_DIR=/host/lib/aarch64-linux-gnu
LAARCH_HOST_DIR=/lib/aarch64-linux-gnu

DEVICES="--device=/dev/nvhost-ctrl
         --device=/dev/nvhost-ctrl-gpu
         --device=/dev/nvhost-prof-gpu
         --device=/dev/nvmap
         --device=/dev/nvhost-gpu
         --device=/dev/nvhost-as-gpu"

VOLUMES="--volume=$XSOCK:$XSOCK:rw
         --volume=$XAUTH:$XAUTH:rw
         --volume=$SHARED_HOST_DIR:$SHARED_DOCK_DIR:rw
         --volume=$__CUDA_HOST_DIR:$__CUDA_DOCK_DIR:ro
         --volume=$__TSRT_HOST_DIR:$__TSRT_DOCK_DIR:ro
         --volume=$UAARCH_HOST_DIR:$UAARCH_DOCK_DIR:ro
         --volume=$LAARCH_HOST_DIR:$LAARCH_DOCK_DIR:ro"

ENVIRONS="-e LD_LIBRARY_PATH=${LD_LIB}
          -e XAUTHORITY=${XAUTH}
          -e DISPLAY=${DISPLAY}
          -e USER_ID=${USER_ID}"

docker run \
    -it --rm \
    $DEVICES \
    $VOLUMES \
    $ENVIRONS \
    --privileged \
    --net=host \
    $RUNTIME \
    $IMAGE
