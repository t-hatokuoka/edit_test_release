DRONE_TAG    ?= dev
DRONE_COMMIT ?= HEAD
ZLAB_UNIT    ?= corp
GITHUB_ORG   ?= zlabjp

VERSION ?= 16.04
TAG     ?= ${DRONE_TAG}

.PHONY: update-release
update-release:
        scripts/update-release.sh ${GITHUB_ORG}/edit_test_release ${TAG} test-${VERSION}-${TAG} 
