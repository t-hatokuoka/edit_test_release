#!/bin/bash

set -eu

TAG=$1
IMAGE_NAME=$2

if [ ! -n "${TAG}" ]; then
  echo "tag required."
  exit 1
fi

if [ ! -n "${IMAGE_NAME}" ]; then
  echo "image name required."
  exit 1
fi

if [ ${ZLAB_UNIT} == "corp" ]; then
  git log v0.0.30..v0.0.31
  curl -H "Accept: application/json" https://ghproxy.corp.zlab.co.jp/api/repos/${GITHUB_USER}/${GITHUB_REPO}/pulls?state=closed | jq '.[] | select(.merged_at != null)' | grep tag
  LIST=$(cat <<EOS
- test1
- test2
EOS
)
elif [ ${ZLAB_UNIT} == "yj" ]; then
  LIST="- https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/tag/${TAG}"
else
  echo "unit required."
  exit 1
fi

DESCRIPTION=$(cat <<EOS
## Change List

$LIST

## Artifacts

| イメージ名 |
| --- |
| ${IMAGE_NAME} |
EOS
)

echo "Updating release..."
github-release edit \
    --tag  ${TAG} \
    --name ${TAG} \
    --description "$DESCRIPTION"
