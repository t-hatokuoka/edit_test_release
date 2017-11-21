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

if [ ${ZLAB_UNIT} == "corp" ]; then
  git fetch

  DIFF_TAGS="--all"

  TWO_TAGS=(`git for-each-ref --sort=-committerdate --format '%(refname:short)' refs/tags | head -n 2`)

  if [ -z ${TWO_TAGS[0]} ]; then
    echo "Failed to get tags."
    exit 1
  fi

  if [ ! -z ${TWO_TAGS[1]} ]; then
    DIFF_TAGS="${TWO_TAGS[1]}..${TWO_TAGS[0]}"
  fi

  IFS_BACKUP=$IFS
  IFS=$'\n'

  PR_TITLES=(`git log --merges --reverse ${DIFF_TAGS} --pretty=format:"%b"`)

  IFS=$IFS_BACKUP

  PR_NUMBERS=(`git log --merges --reverse ${DIFF_TAGS} --pretty=format:"%s" | sed -e 's/^.*#\([0-9]*\).*$/\1/'`)

  for i in `seq ${#PR_TITLES[*]}`
  do
    PR_LIST=$(cat <<EOS
${PR_LIST}
- ${PR_TITLES[${i}-1]} #${PR_NUMBERS[${i}-1]}
EOS
)
  done

  if [ -z "${PR_LIST}" ]; then
    echo "Failed to get pull request list."
    exit 1
  fi
elif [ ${ZLAB_UNIT} == "yj" ]; then
  PR_LIST="- https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/tag/${TAG}"
  RELEASE_COMMAND=release
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
github-release ${RELEASE_COMMAND} \
    --tag  ${TAG} \
    --name ${TAG} \
    --description "${DESCRIPTION}"
