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

HOGE=`cat << EOS
## Change List

- Update ansible-infra-common v1.21.0

| イメージ名 |
| --- |
| ${IMAGE_NAME} |
EOS
`

echo "Updating release..."
github-release edit \
    --repo ${GITHUB_REPO} \
    --tag  ${TAG} \
    --name ${TAG} \
    --description "## Change List

- Update ansible-infra-common v1.21.0

| イメージ名 |
| --- |
| ${IMAGE_NAME} |
"
