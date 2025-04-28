SHELL=/bin/bash
.DEFAULT_GOAL:=help

C_NO           = "\033[0m" # No Color
C_BLACK        = "\033[0;30m"
C_DARK_GRAY    = "\033[1;30m"
C_RED          = "\033[0;31m"
C_LIGHT_RED    = "\033[1;31m"
C_GREEN        = "\033[0;32m"
C_LIGHT_GREEN  = "\033[1;32m"
C_BROWN        = "\033[0;33m"
C_YELLOW       = "\033[1;33m"
C_BLUE         = "\033[0;34m"
C_LIGHT_BLUE   = "\033[1;34m"
C_PURPLE       = "\033[0;35m"
C_LIGHT_PURPLE = "\033[1;35m"
C_CYAN         = "\033[0;36m"
C_LIGHT_CYAN   = "\033[1;36m"
C_LIGHT_GRAY   = "\033[0;37m"
C_WHITE        = "\033[1;37m"
MARKER_START   = "+----------------+"
MARKER_END     = "+----------------+"

.PHONY: help
##@ Helpers
help:  ## Display this help
	@awk  'BEGIN { \
	FS = ":.*##"; \
	printf "Usage:\nmake [VARS] %s<target>%s\n", $(C_CYAN), $(C_NO)} /^[a-zA-Z_-]+:.*?##/  \
	{ printf " %s %-15s%s %s\n", $(C_CYAN), $$1, $(C_NO), $$2} /^##@/ \
	{ printf "\n%s%s%s\n", $(C_WHITE),substr($$0, 5), $(C_NO)} ' $(MAKEFILE_LIST)
###########################################################################

include .build.props.ini
include .env

DOCKER_BUILDKIT=1

FROM_DEV_IMAGE=node:${NODE_VERSION}
BUILD_DEV_REPOSITORY=${REPOSITORY_DOMAIN}/frontend-dev
BUILD_DEV_IMAGE=${BUILD_DEV_REPOSITORY}:${DEV_VERSION}

CONSOLE=/bin/bash

BUILD_DEV_CMD := docker build -f Dockerfile.dev \
    --build-arg FROM_IMAGE=$(FROM_DEV_IMAGE) \
	--build-arg ANGULAR_VERSION=$(ANGULAR_VERSION) \
	-t $(BUILD_DEV_IMAGE) .

##@ Dev
info: ## Info
	@echo build image $(BUILD_DEV_IMAGE)

lint: ## Lint Dockerfile.dev
	@docker run --rm -i hadolint/hadolint < Dockerfile.dev

dev-build: lint ## Build an image from a Dockerfile.dev
	@$(BUILD_DEV_CMD)

dev-has-image:
	@docker inspect --format={{.Created}} $(BUILD_DEV_IMAGE)

dev-push: dev-has-image ## Push an image or a repository to a registry.
	@docker push $(BUILD_DEV_IMAGE)

dev-publish: dev-build dev-push  ## Build an image from a Dockerfile.dev and Push an image

up: dev-has-image ## Run a console in a new container
	@ export BUILD_IMAGE=$(BUILD_DEV_IMAGE) && docker compose -f docker-compose.dev.yml up -d

kill:  ## Remove dev console container
	@export BUILD_IMAGE=$(BUILD_DEV_IMAGE) && docker compose -f docker-compose.dev.yml kill

rm: kill ## Remove dev console container
	@export BUILD_IMAGE=$(BUILD_DEV_IMAGE) \
	&& docker compose -f docker-compose.dev.yml rm -f

console: up ## Run a bash in a new container
	@docker exec -it $(DEV_CONTAINER_NAME) /bin/bash

##@ Prod
BUILD_APP_REPOSITORY=${REPOSITORY_DOMAIN}/frontend
BUILD_APP_IMAGE=${BUILD_APP_REPOSITORY}:${APP_VERSION}
BUILD_APP_CMD := docker build -f Dockerfile \
	-t $(BUILD_APP_IMAGE) .

build: ## Build an image from a Dockerfile
	@$(BUILD_APP_CMD)

publish: build push  ## Build an image from a Dockerfilev and Push an image or a repository to a registry.

has-image:
	@docker inspect --format={{.Created}} $(BUILD_IMAGE)

push: has-image ## Push an image or a repository to a registry.
	@docker push $(BUILD_APP_IMAGE)
