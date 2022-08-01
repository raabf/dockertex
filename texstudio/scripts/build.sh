#!/bin/bash

# $IMAGE_NAME var is injected into the build so the tag is correct.

echo "--build.sh hook called--"
echo "build.sh: IMAGE_NAME '$IMAGE_NAME'"
echo "build.sh: DOCKERFILE_PATH '$DOCKERFILE_PATH'"
echo "build.sh: CACHE_TAG '$CACHE_TAG'"
echo "build.sh: IMAGE_TAG '$IMAGE_TAG'"
echo "build.sh: DOCKER_REGISTRY_DOMAIN '$DOCKER_REGISTRY_DOMAIN'"
echo "build.sh: DOCKER_REGISTRY_REPO '$DOCKER_REGISTRY_REPO'"
echo "build.sh: SOURCE_BRANCH '$SOURCE_BRANCH'"
echo "build.sh: SOURCE_COMMIT '$SOURCE_COMMIT'"
echo "build.sh: PUSH_ENABLED '$PUSH_ENABLED'"
echo "build.sh: TEXSTUDIO_VERSION '$TEXSTUDIO_VERSION'"

. "$(dirname "$DOCKERFILE_PATH")/env_file_all"

echo "build.sh hook: TEXSTUDIO_VERSION_QT4 '$TEXSTUDIO_VERSION_QT4'"
echo "build.sh hook: TEXSTUDIO_VERSION_QT5 '$TEXSTUDIO_VERSION_QT5'"
echo "build.sh hook: TEXSTUDIO_VERSION_QT5_DEBIAN9 '$TEXSTUDIO_VERSION_QT5_DEBIAN9'"
echo "build.sh hook: TEXSTUDIO_VERSION_QT5_DEBIAN10 '$TEXSTUDIO_VERSION_QT5_DEBIAN10'"

FINAL_IMAGE_NAME=${IMAGE_NAME:-$DOCKER_REGISTRY_DOMAIN/$DOCKER_REGISTRY_REPO}

# curl --silent http://download.opensuse.org/repositories/home:/jsundermeyer/Debian_11/amd64/ | grep -o -e "texstudio_4.2.3[^\"]*.deb" | head -n 1

declare -A basemap # Base image to build FROM
declare -A versionmap # The installed texlive version for documentation
declare -A baseurl # The OS version specific part of the Texstudio download URL

versionmap[stretch]="2016";     basemap[stretch]="raabf/latex-versions:stretch";      baseurl[stretch]="Debian_9.0/amd64"
versionmap[bionic]="2017";      basemap[bionic]="raabf/latex-versions:bionic";        baseurl[bionic]="xUbuntu_18.04/amd64"
versionmap[buster]="2018";      basemap[buster]="raabf/latex-versions:buster";        baseurl[buster]="Debian_10/amd64"
versionmap[focal]="2019";       basemap[focal]="raabf/latex-versions:focal";          baseurl[focal]="xUbuntu_20.04/amd64"
versionmap[bullseye]="2020";    basemap[bullseye]="raabf/latex-versions:bullseye";    baseurl[bullseye]="Debian_11/amd64"
versionmap[jammy]="2021";       basemap[jammy]="raabf/latex-versions:jammy";          baseurl[jammy]="xUbuntu_21.10/amd64"  # TODO change to xUbuntu_22.04/amd64/ (21.10 is impish)
versionmap[bookworm]="2022";    basemap[bookworm]="raabf/latex-versions:bookworm";    baseurl[bookworm]="Debian_Testing/amd64"

URL_PREFIX="http://download.opensuse.org/repositories/home:/jsundermeyer"

filename="$(curl --silent ${URL_PREFIX}/${baseurl[${IMAGE_TAG##*-}]} | grep -o -e "texstudio_${TEXSTUDIO_VERSION}[^\"]*.deb" | head -n 1)"
echo "Found file name on ${URL_PREFIX}/${baseurl[${IMAGE_TAG##*-}]} : ${filename}"

full_url="${URL_PREFIX}/${baseurl[${IMAGE_TAG##*-}]}/${filename}"
echo "Set full download URL to: ${full_url}"

docker build --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
            --build-arg VCS_REF=$(git rev-parse --short HEAD) \
            --build-arg TEXLIVE_VERSION="${versionmap[${IMAGE_TAG##*-}]}" \
            --build-arg TEXSTUDIO_VERSION="${TEXSTUDIO_VERSION}" \
            --build-arg TEXSTUDIO_FILENAME="${filename}" \
            --build-arg BASE_IMAGE="${basemap[${IMAGE_TAG}]}" \
            --build-arg FULL_URL="${full_url}" \
            --build-arg TEXSTUDIO_VERSION_QT4="$TEXSTUDIO_VERSION_QT4" \
            --build-arg TEXSTUDIO_VERSION_QT5="$TEXSTUDIO_VERSION_QT5" \
            --build-arg TEXSTUDIO_VERSION_QT5_DEBIAN9="$TEXSTUDIO_VERSION_QT5_DEBIAN9" \
            --build-arg TEXSTUDIO_VERSION_QT5_DEBIAN10="$TEXSTUDIO_VERSION_QT5_DEBIAN10" \
            --file "$DOCKERFILE_PATH" --tag "$FINAL_IMAGE_NAME:$IMAGE_TAG" . || exit $?

if [[ "$PUSH_ENABLED" == 'true' ]]; then
    docker push "$FINAL_IMAGE_NAME:$IMAGE_TAG" || exit $?
fi
