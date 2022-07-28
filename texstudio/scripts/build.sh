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

. "$(dirname "$DOCKERFILE_PATH")/env_file_all"
echo "build.sh hook: TEXSTUDIO_VERSION_QT4 '$TEXSTUDIO_VERSION_QT4'"
echo "build.sh hook: TEXSTUDIO_VERSION_QT5 '$TEXSTUDIO_VERSION_QT5'"
echo "build.sh hook: TEXSTUDIO_VERSION_QT5_DEBIAN9 '$TEXSTUDIO_VERSION_QT5_DEBIAN9'"
echo "build.sh hook: TEXSTUDIO_VERSION_QT5_DEBIAN10 '$TEXSTUDIO_VERSION_QT5_DEBIAN10'"

docker build --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
            --build-arg VCS_REF=$(git rev-parse --short HEAD) \
            --build-arg TEXSTUDIO_VERSION_QT4="$TEXSTUDIO_VERSION_QT4" \
            --build-arg TEXSTUDIO_VERSION_QT5="$TEXSTUDIO_VERSION_QT5" \
            --build-arg TEXSTUDIO_VERSION_QT5_DEBIAN9="$TEXSTUDIO_VERSION_QT5_DEBIAN9" \
            --build-arg TEXSTUDIO_VERSION_QT5_DEBIAN10="$TEXSTUDIO_VERSION_QT5_DEBIAN10" \
            --file "$DOCKERFILE_PATH" --tag "$FINAL_IMAGE_NAME:$IMAGE_TAG" .

if [[ "$PUSH_ENABLED" == 'true' ]]; then
    docker push "$FINAL_IMAGE_NAME:$IMAGE_TAG"
fi
