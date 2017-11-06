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

echo "Updating release..."
github-release edit \
    --repo ${GITHUB_REPO} \
    --tag  ${TAG} \
    --name ${TAG} \
    --description "## Change List\\r\\n\\r\\n- Update ansible-infra-common v1.21.0 #14\\r\\n\\r\\n## Artifacts\\r\\n\\r\\n\\r\\n| イメージ名 |\\r\\n| --- |\\r\\n| ${IMAGE_NAME} |"
