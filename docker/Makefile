
IMAGE_NAME ?= centos

BUILD_FLAGS ?= --rm
START_FLAGS ?= -d --remove-orphans
REMOVE_FLAGS ?= --force

docker_file := dev/$(IMAGE_NAME).dockerfile
compose_file := compose/$(IMAGE_NAME)-dev.yaml
image_tag := junjiemars/$(IMAGE_NAME)-dev:latest
bone_dev_container := bone-$(IMAGE_NAME)-dev


build: $(docker_file)
	docker build $(BUILD_FLAGS) -t $(image_tag) -f $< .

start: $(compose_file) stop
	docker-compose -f $<  up $(START_FLAGS)

stop: $(compose_file)
	docker-compose -f $<  stop

exec: start
	docker exec -e LINES=$(LINES) \
							-e COLUMNS=$(COLUMNS) \
							-e TERM=$(TERM) \
							-it -u u \
							$(bone_dev_container) /bin/bash

remove: $(compose_file) stop
	docker-compose -f $<  rm $(REMOVE_FLAGS)

clean: $(compose_file) remove
	docker rmi $(image_tag)

push: build
	docker push $(image_tag)

pull:
	docker pull $(image_tag)

.PHONY: build start stop exec remove clean push pull
