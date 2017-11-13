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
  PREV_TAG=(`curl -H "Accept: application/json" https://ghproxy.corp.zlab.co.jp/api/repos/${GITHUB_USER}/${GITHUB_REPO}/releases | jq -r '.[1] | .tag_name'`)
  DIFF_COMMITS=(`curl -H "Accept: application/json" https://ghproxy.corp.zlab.co.jp/api/repos/${GITHUB_USER}/${GITHUB_REPO}/compare/${PREV_TAG}...master | jq -r '.commits[].sha'`)
  PULLS=`curl -H "Accept: application/json" https://ghproxy.corp.zlab.co.jp/api/repos/${GITHUB_USER}/${GITHUB_REPO}/pulls?state=closed`

  for commit in ${DIFF_COMMITS[@]}
  do
    PR_NUMBER=`echo ${PULLS} | jq -r --arg sha ${commit} '.[] | select(.merge_commit_sha == $sha) | .number'`
    if [ ! -z ${PR_NUMBER} ]; then
      PR_TITLE="- `echo ${PULLS} | jq -r --arg sha ${commit} '.[] | select(.merge_commit_sha == $sha) | .title'` #${PR_NUMBER}"

      PR_LIST=$(cat <<EOS
$PR_LIST
$PR_TITLE
EOS
)
elif [ ${ZLAB_UNIT} == "yj" ]; then
  PR_LIST="- https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/tag/${TAG}"
else
  echo "unit required."
  exit 1
fi

DESCRIPTION=$(cat <<EOS
## Change List

$PR_LIST

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
