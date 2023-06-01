#!/bin/bash

echo "--tag_alias.sh script called--"
echo "tag_alias.sh: IMAGE_NAME '$IMAGE_NAME'"
echo "tag_alias.sh: DOCKERFILE_PATH '$DOCKERFILE_PATH'"
echo "tag_alias.sh: CACHE_TAG '$CACHE_TAG'"
echo "tag_alias.sh: IMAGE_TAG '$IMAGE_TAG'"
echo "tag_alias.sh: DOCKER_REGISTRY_DOMAIN '$DOCKER_REGISTRY_DOMAIN'"
echo "tag_alias.sh: DOCKER_REGISTRY_REPO '$DOCKER_REGISTRY_REPO'"
echo "tag_alias.sh: SOURCE_BRANCH '$SOURCE_BRANCH'"
echo "tag_alias.sh: SOURCE_COMMIT '$SOURCE_COMMIT'"
echo "tag_alias.sh: PUSH_ENABLED '$PUSH_ENABLED'"

declare -A aliasmap

aliasmap[foobar]="texlive1700"
aliasmap[wheezy]="texlive2012"
aliasmap[trusty]="texlive2013"
aliasmap[jessie]="texlive2014"
aliasmap[xenial]="texlive2015"
aliasmap[stretch]="texlive2016"
aliasmap[bionic]="texlive2017"
aliasmap[buster]="texlive2018"
aliasmap[focal]="texlive2019"
aliasmap[bullseye]="texlive2020"
aliasmap[jammy]="texlive2021 latest"
aliasmap[bookworm]="texlive2022 testing"


mapfile -t array < <(echo "${aliasmap[${IMAGE_TAG##*-}]}")
echo "tag_alias.sh: use alias list '${array[@]}'"

DOCKER_REGISTRY_IMAGE_NAME="${DOCKER_REGISTRY_REPO:+${DOCKER_REGISTRY_DOMAIN:-docker.io}/$DOCKER_REGISTRY_REPO}"
FINAL_IMAGE_NAME=${IMAGE_NAME:-${DOCKER_REGISTRY_IMAGE_NAME:-latex}}
echo "tag_alias.sh: FINAL_IMAGE_NAME '$FINAL_IMAGE_NAME'"

for aliastag in ${array[@]}; do

	if [[ ${IMAGE_TAG%%-*} == "arm"* ]]; then
		# Prefix the alias tag with the architecture if not x86 (e.g armhf-texlive2017)
		aliastag="${IMAGE_TAG%%-*}-${aliastag}"
	fi


    echo "tag_alias.sh: tag '$FINAL_IMAGE_NAME:$aliastag'"
    docker tag "$FINAL_IMAGE_NAME:$IMAGE_TAG" "$FINAL_IMAGE_NAME:$aliastag" || exit $?

	if [[ "$PUSH_ENABLED" == 'true' ]]; then
		echo "tag_alias.sh: push '$FINAL_IMAGE_NAME:$aliastag'"
	    docker push $FINAL_IMAGE_NAME:$aliastag || exit $?
	fi

done

