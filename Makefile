help:
	@echo "Please select target"
	@echo "build - build the docker image"

build:
	docker build -t dbainbriciena/ones-config-validator:1.0 .
