VERSION=0.1.0
IMAGE_NAME=sharavara/ping

.PHONY: build push

build:
	./build.sh false

push:
	./build.sh true