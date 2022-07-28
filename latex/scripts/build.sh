#!/bin/bash

echo "--build.sh called--"
echo "build.sh: IMAGE_NAME '$IMAGE_NAME'"
echo "build.sh: DOCKERFILE_PATH '$DOCKERFILE_PATH'"
echo "build.sh: CACHE_TAG '$CACHE_TAG'"
echo "build.sh: IMAGE_TAG '$IMAGE_TAG'"
echo "build.sh: DOCKER_REGISTRY_DOMAIN '$DOCKER_REGISTRY_DOMAIN'"
echo "build.sh: DOCKER_REGISTRY_REPO '$DOCKER_REGISTRY_REPO'"
echo "build.sh: SOURCE_BRANCH '$SOURCE_BRANCH'"
echo "build.sh: SOURCE_COMMIT '$SOURCE_COMMIT'"
echo "build.sh: PUSH_ENABLED '$PUSH_ENABLED'"

declare -A basemap # Base image to build FROM
declare -A versionmap # The installed texlive version for documentation
declare -A pkgmap # Additional per distribution packages
declare -A debmap # Additional repository line for apt/sources.list

#                                                          For ubuntu in debmap it would be “http://archive.ubuntu.com/ubuntu/ trusty multiverse”, but it is already activated
versionmap[foobar]="1700";  basemap[foobar]="debian:buster";   pkgmap[foobar]="python3-pygments"; debmap[foobar]="deb http://deb.debian.org/debian/ buster contrib non-free"
versionmap[wheezy]="2012";  basemap[wheezy]="debian:wheezy";   pkgmap[wheezy]="python-pygments";  debmap[wheezy]="deb http://deb.debian.org/debian/ wheezy contrib non-free"
versionmap[trusty]="2013";  basemap[trusty]="ubuntu:trusty";   pkgmap[trusty]="python-pygments";  debmap[trusty]=""
versionmap[jessie]="2014";  basemap[jessie]="debian:jessie";   pkgmap[jessie]="python-pygments";  debmap[jessie]="deb http://deb.debian.org/debian/ jessie contrib non-free"
versionmap[xenial]="2015";  basemap[xenial]="ubuntu:xenial";   pkgmap[xenial]="python-pygments";  debmap[xenial]=""
versionmap[stretch]="2016"; basemap[stretch]="debian:stretch"; pkgmap[stretch]="python-pygments"; debmap[stretch]="deb http://deb.debian.org/debian/ stretch contrib non-free"
versionmap[bionic]="2017";  basemap[bionic]="ubuntu:bionic";   pkgmap[bionic]="python-pygments";  debmap[bionic]=""
versionmap[buster]="2018";  basemap[buster]="debian:buster";   pkgmap[buster]="python3-pygments"; debmap[buster]="deb http://deb.debian.org/debian/ buster contrib non-free"
versionmap[focal]="2019";   basemap[focal]="ubuntu:focal";     pkgmap[focal]="python3-pygments";  debmap[focal]=""
versionmap[sid]="2020";     basemap[sid]="debian:sid";         pkgmap[sid]="python3-pygments";    debmap[sid]="deb http://deb.debian.org/debian/ unstable contrib non-free"

basemap[armhf-jessie]="multiarch/debian-debootstrap:armhf-jessie";   basemap[arm64-jessie]="multiarch/debian-debootstrap:arm64-jessie";   
basemap[armhf-xenial]="multiarch/ubuntu-debootstrap:armhf-xenial";   basemap[arm64-xenial]="multiarch/ubuntu-debootstrap:arm64-xenial";   
basemap[armhf-stretch]="multiarch/debian-debootstrap:armhf-stretch"; basemap[arm64-stretch]="multiarch/debian-debootstrap:arm64-stretch"; 
basemap[armhf-bionic]="multiarch/ubuntu-debootstrap:armhf-bionic";   basemap[arm64-bionic]="multiarch/ubuntu-debootstrap:arm64-bionic";   
basemap[armhf-buster]="multiarch/debian-debootstrap:armhf-buster";   basemap[arm64-buster]="multiarch/debian-debootstrap:arm64-buster";   
basemap[armhf-focal]="multiarch/ubuntu-debootstrap:armhf-focal";   basemap[arm64-bionic]="multiarch/ubuntu-debootstrap:arm64-focal";   
basemap[armhf-sid]="multiarch/debian-debootstrap:armhf-sid";         basemap[arm64-sid]="multiarch/debian-debootstrap:arm64-sid";         


FINAL_IMAGE_NAME=${IMAGE_NAME:-$DOCKER_REGISTRY_DOMAIN/$DOCKER_REGISTRY_REPO}

# $IMAGE_NAME var is injected into the build so the tag is correct.
docker build --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
             --build-arg VCS_REF=$(git rev-parse --short HEAD) \
             --build-arg BASE_IMAGE="${basemap[${IMAGE_TAG}]}" \
             --build-arg TEXLIVE_VERSION="${versionmap[${IMAGE_TAG##*-}]}" \
             --build-arg PACKAGES_INSTALL="${pkgmap[${IMAGE_TAG##*-}]}" \
             --build-arg DEBLINE="${debmap[${IMAGE_TAG##*-}]}" \
             --file "$DOCKERFILE_PATH" --tag "$FINAL_IMAGE_NAME:$IMAGE_TAG" . || exit $?

if [[ "$PUSH_ENABLED" == 'true' ]]; then
    docker push "$FINAL_IMAGE_NAME:$IMAGE_TAG" || exit $?
fi