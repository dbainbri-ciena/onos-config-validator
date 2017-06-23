help:
	@echo "Please select target"
	@echo "build - build the docker image"

build:
	docker build -t dbainbriciena/onos-config-validator:1.0 .
