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

PR_LIST=
RELEASE_COMMAND=edit

if [ "${ZLAB_UNIT}" == "corp" ]; then
  git fetch

  DIFF_TAGS="--all"

  TWO_TAGS=(`git for-each-ref --sort=-committerdate --format '%(refname:short)' refs/tags | head -n 2`)

  if [ -z "${TWO_TAGS[0]}" ]; then
    echo "Failed to get tags."
    exit 1
  fi

  if [ ! -z "${TWO_TAGS[1]}" ]; then
    DIFF_TAGS="${TWO_TAGS[1]}..${TWO_TAGS[0]}"
  fi

  PR_LIST=$(cat <<EOS
`git log --merges --reverse --grep="Merge branch 'master'" --invert-grep ${DIFF_TAGS} --pretty=format:"- %b %s" | sed -e 's/^\(.*\)Merge pull request \(#[0-9]*\).*$/\1\2/' | awk 'NR>1&&/^- /{print ""}{printf $0}END{print ""}'`
EOS
)

  if [ -z "${PR_LIST}" ]; then
    echo "Failed to get pull request list."
    exit 1
  fi
elif [ "${ZLAB_UNIT}" == "yj" ]; then
  PR_LIST="- https://github.com/zlabjp/${GITHUB_REPO}/releases/tag/${TAG}"
  RELEASE_COMMAND=release
else
  echo "Unit is unset or invalid value."
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

echo "Displaying set value..."
echo "GITHUB_REPO=${GITHUB_REPO}, GITHUB_USER=${GITHUB_USER}, RELEASE_COMMAND=${RELEASE_COMMAND}, TAG=${TAG}"
echo "DESCRIPTION=
${DESCRIPTION}"

echo "Updating release..."
github-release ${RELEASE_COMMAND} \
    --tag  v0.0.58 \
    --name ${TAG} \
    --description "${DESCRIPTION}"
