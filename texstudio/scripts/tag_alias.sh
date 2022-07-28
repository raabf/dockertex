#!/bin/bash

echo "--tag_alias.sh hook called--"
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
aliasmap[stretch]="texlive2016 latest"
aliasmap[bionic]="texlive2017"
aliasmap[buster]="texlive2018 testing"
aliasmap[sid]="texlive2019"


array=( $(echo ${aliasmap[${IMAGE_TAG##*-}]}) )
echo "tag_alias.sh: use alias list '${array[@]}'"

FINAL_IMAGE_NAME=${IMAGE_NAME:-$DOCKER_REGISTRY_DOMAIN/$DOCKER_REGISTRY_REPO}

for aliastag in ${array[@]}; do
    
    echo "tag_alias.sh: tag '$FINAL_IMAGE_NAME:$aliastag'"
    docker tag "$FINAL_IMAGE_NAME:$IMAGE_TAG" "$FINAL_IMAGE_NAME:$aliastag" || exit $?

	if [[ "$PUSH_ENABLED" == 'true' ]]; then
		echo "tag_alias.sh: push '$FINAL_IMAGE_NAME:$aliastag'"
	    docker push $FINAL_IMAGE_NAME:$aliastag || exit $?
	fi

done

