DRONE_TAG       ?= dev
DRONE_COMMIT    ?= HEAD
DRONE_DEPLOY_TO ?= stage

TAG       ?= ${DRONE_TAG}
COMMIT    ?= $(shell echo ${DRONE_COMMIT} | cut -c 1-7)
DEPLOY_TO ?= ${DRONE_DEPLOY_TO}

IMAGE_BASE_NAME := ubuntu-16.04-zlab.1

BUILD_LABEL   := build
BUILD_VERSION := ${BUILD_LABEL}-${COMMIT}

IMAGE_NAME         := test-hatokuoka
IMAGE_FILE_NAME    := ${IMAGE_NAME}.qcow2
IMAGE_BUILD_PREFIX := ${IMAGE_NAME}-${BUILD_LABEL}
IMAGE_BUILD_NAME   := ${IMAGE_NAME}-${BUILD_VERSION}
IMAGE_RELEASE_NAME := ${IMAGE_NAME}-${TAG}

.PHONY: all
all: image

.PHONY: check
check:
	image-check node.json

.PHONY: validate
validate:
	image-validate node.json

.PHONY: image
image:
	image-build node.json ${IMAGE_BASE_NAME} ${IMAGE_BUILD_NAME}

.PHONY: compress
compress:
	image-pull ${IMAGE_BUILD_NAME} ${IMAGE_FILE_NAME}.tmp
	image-delete ${IMAGE_BUILD_NAME}
	image-compress ${IMAGE_FILE_NAME}.tmp ${IMAGE_FILE_NAME}
	image-push ${IMAGE_FILE_NAME} ${IMAGE_BUILD_NAME}
	rm ${IMAGE_FILE_NAME}.tmp

.PHONY: prune
prune:
	image-prune ${IMAGE_BUILD_PREFIX} 5

.PHONY: promote
promote:
	image-rename ${IMAGE_BUILD_NAME} ${IMAGE_RELEASE_NAME}

.PHONY: test
test:
	tf apply terraform/etcd.tf --workspace ci --image-version "${BUILD_VERSION}" --cleanup

.PHONY: github-release
github-release:
	github-release-update infra-etcd ${TAG}

.PHONY: deploy
deploy:
	tf rolling-update terraform/etcd.tf --workspace ${DEPLOY_TO} --image-version ${TAG} --instance-module test

.PHONY: drone-secret
drone-secret:
	scripts/sync-drone-secret.sh

.PHONY: terraform-modules
terraform-modules:
	git submodule init
	git submodule update

.PHONY: update-terraform-modules
update-terraform-modules:
	git submodule foreach git pull origin master

.PHONY: clean
clean:
	rm -rf *.qcow2*
	rm -rf manifest.json
	rm -rf packer_cache
