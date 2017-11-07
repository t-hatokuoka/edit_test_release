#!/bin/bash

set -eu

GITHUB_REPO=$1
TAG=$2
IMAGE_NAME=$3

if [ ! -n "${GITHUB_REPO}" ]; then
  echo "github repository required."
  exit 1
fi

if [ ! -n "${TAG}" ]; then
  echo "tag required."
  exit 1
fi

if [ ! -n "${IMAGE_NAME}" ]; then
  echo "image name required."
  exit 1
fi

if [ ${ZLAB_UNIT} == "corp" ]; then
  LIST="- Update ansible-infra-common v1.21.0"
elif [ ${ZLAB_UNIT} == "yj" ]; then
  LIST="- https://github.com/t-hatokuoka/${GITHUB_REPO}/releases/tag/${TAG}"
else
  echo "unit required."
  exit 1
fi

DESCRIPTION=$(cat <<EOS
## Change List

${LIST}

## Artifacts

| イメージ名 |
| --- |
| ${IMAGE_NAME} |
EOS
)

echo "Updating release..."
github-release edit \
    --user "t-hatokuok"
    --repo ${GITHUB_REPO} \
    --tag  ${TAG} \
    --name ${TAG} \
    --description "$DESCRIPTION"
