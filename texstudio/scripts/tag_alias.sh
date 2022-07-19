#!/bin/bash

echo "--tag_alias.sh hook called--"
echo "tag_alias.sh: IMAGE_NAME '$IMAGE_NAME'"
echo "tag_alias.sh: DOCKERFILE_PATH '$DOCKERFILE_PATH'"
echo "tag_alias.sh: CACHE_TAG '$CACHE_TAG'"
echo "tag_alias.sh: DOCKER_TAG '$DOCKER_TAG'"
echo "tag_alias.sh: DOCKER_REPO '$DOCKER_REPO'"
echo "tag_alias.sh: SOURCE_BRANCH '$SOURCE_BRANCH'"
echo "tag_alias.sh: SOURCE_COMMIT '$SOURCE_COMMIT'"

declare -A aliasmap

aliasmap[wheezy]="texlive2012"
aliasmap[trusty]="texlive2013"
aliasmap[jessie]="texlive2014"
aliasmap[xenial]="texlive2015"
aliasmap[stretch]="texlive2016 latest"
aliasmap[bionic]="texlive2017"
aliasmap[buster]="texlive2018 testing"
aliasmap[sid]="texlive2019"


array=( $(echo ${aliasmap[$DOCKER_TAG]}) )
echo "tag_alias.sh: use alias list '${aliasmap[$DOCKER_TAG]}'"

for aliastag in ${array[@]}; do
    
    echo "tag_alias.sh: tag and push '$aliastag'"
    docker tag $IMAGE_NAME $DOCKER_REPO:$aliastag
    docker push $DOCKER_REPO:$aliastag

done

