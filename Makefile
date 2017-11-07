DRONE_TAG    ?= dev
DRONE_COMMIT ?= HEAD
ZLAB_UNIT    ?= corp

VERSION ?= 16.04
TAG     ?= ${DRONE_TAG}

.PHONY: update-release
update-release:
	scripts/update-release.sh ${TAG} test-${VERSION}-${TAG} 
