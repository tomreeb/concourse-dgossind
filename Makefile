NS ?= tomreeb
VERSION ?= $(shell cat version.txt)
IMAGE_NAME ?= concourse-dgossind
CONTAINER_NAME ?= concourse-dgossind
CONTAINER_INSTANCE ?= default

.PHONY: build push shell run start stop rm beta-release release

build: Dockerfile
	docker build -t $(NS)/$(IMAGE_NAME)\:$(VERSION) -f Dockerfile .

push:
	docker push $(NS)/$(IMAGE_NAME)\:$(VERSION)

lint:
	docker run -it --rm --privileged -v `pwd`:/root/ projectatomic/dockerfile-lint dockerfile_lint

test:
	dgoss run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(NS)/$(IMAGE_NAME)\:$(VERSION)

shell:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(NS)/$(IMAGE_NAME)\:$(VERSION) /bin/ash

run:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(NS)/$(IMAGE_NAME)\:$(VERSION)

start:
	docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(NS)/$(IMAGE_NAME)\:$(VERSION)

stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)
	
rm:
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

beta-release: build
	docker tag $(APP):$(VERSION) $(REMOTE_TAG)-BETA
	docker push $(REMOTE_TAG)-BETA

release: lint build test
	docker tag $(APP):$(VERSION) $(REMOTE_TAG)
	docker tag $(APP):$(VERSION) $(LATEST_TAG)
	docker push $(REMOTE_TAG)
	docker push $(LATEST_TAG)
    
default: build