#!/bin/bash

echo "--aliastag.sh script called--"
echo "aliastag.sh: IMAGE_NAME '$IMAGE_NAME'"
echo "aliastag.sh: DOCKERFILE_PATH '$DOCKERFILE_PATH'"
echo "aliastag.sh: CACHE_TAG '$CACHE_TAG'"
echo "aliastag.sh: IMAGE_TAG '$IMAGE_TAG'"
echo "aliastag.sh: DOCKER_REGISTRY_DOMAIN '$DOCKER_REGISTRY_DOMAIN'"
echo "aliastag.sh: DOCKER_REGISTRY_REPO '$DOCKER_REGISTRY_REPO'"
echo "aliastag.sh: SOURCE_BRANCH '$SOURCE_BRANCH'"
echo "aliastag.sh: SOURCE_COMMIT '$SOURCE_COMMIT'"
echo "aliastag.sh: PUSH_ENABLED '$PUSH_ENABLED'"

declare -A aliasmap

aliasmap[foobar]="texlive1700"
aliasmap[wheezy]="texlive2012"
aliasmap[trusty]="texlive2013"
aliasmap[jessie]="texlive2014"
aliasmap[xenial]="texlive2015"
aliasmap[stretch]="texlive2016 latest"
aliasmap[bionic]="texlive2017"
aliasmap[buster]="texlive2018"
aliasmap[focal]="texlive2019 testing"
aliasmap[sid]="texlive2020"

array=( $(echo ${aliasmap[${IMAGE_TAG##*-}]}) )
echo "aliastag.sh: use alias list '${array[@]}'"

FINAL_IMAGE_NAME=${IMAGE_NAME:-$DOCKER_REGISTRY_DOMAIN/$DOCKER_REGISTRY_REPO}

for aliastag in ${array[@]}; do
    
	if [[ ${IMAGE_TAG%%-*} == "arm"* ]]; then
		# Prefix the alias tag with the architecture if not x86 (e.g armhf-texlive2017)
		aliastag="${IMAGE_TAG%%-*}-${aliastag}"
	fi


    echo "aliastag.sh: tag '$FINAL_IMAGE_NAME:$aliastag'"
    docker tag "$FINAL_IMAGE_NAME:$IMAGE_TAG" "$FINAL_IMAGE_NAME:$aliastag"

	if [[ "$PUSH_ENABLED" == 'true' ]]; then
		echo "aliastag.sh: push '$FINAL_IMAGE_NAME:$aliastag'"
	    docker push $FINAL_IMAGE_NAME:$aliastag
	fi

done

