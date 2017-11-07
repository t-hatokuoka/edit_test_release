DRONE_TAG    ?= dev
DRONE_COMMIT ?= HEAD
ZLAB_UNIT    ?= corp

VERSION ?= 16.04
TAG     ?= ${DRONE_TAG}

.PHONY: update-release
update-release:
	scripts/update-release.sh {ZLAB_UNIT} edit_test_release ${TAG} test-${VERSION}-${TAG} 
