#! /bin/bash

set -e

log() {
    (echo -e "\e[91m\e[1m$*\e[0m")
}

cleanup() {
    if [ "$containerid" == "" ]; then
        return 0
    fi

     if [ "$1" == "error" ]; then
        log "error occurred, cleaning up..."
    elif [ "$1" != "" ]; then
        log "$1 received, please wait a few seconds for cleaning up..."
    else
        log "cleaning up..."
    fi

    docker ps -a | grep -q $containerid && docker rm -f $containerid
}

trap "cleanup SIGINT" SIGINT
trap "cleanup SIGTERM" SIGTERM
trap "cleanup error" 0
trap "cleanup" EXIT

log  "Building in a container..."

randstr=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
containerid=redeclipse-appimage-build-$randstr
imageid="redeclipse-appimage-build"

log "Building Docker container"
(set -xe; docker build -t $imageid .)

export VERSION BRANCH ARCH REPO_URL BUILD_CLIENT BUILD_SERVER

log "Creating container $containerid"
mkdir -p worspace/ out/
chmod o+rwx,u+s out/
set -xe
docker run -it \
    --name $containerid \
    -v "$(readlink -f out/):/out" \
    -e VERSION -e BRANCH -e ARCH -e REPO_URL -e BUILD_CLIENT -e BUILD_SERVER \
    $imageid \
    bash -x /build-appimages.sh
