all: build test

build:
	docker build -t mtneug/opencast:allinone Dockerfiles/allinone
	docker build -t mtneug/opencast:admin Dockerfiles/admin
	docker build -t mtneug/opencast:presentation Dockerfiles/presentation
	docker build -t mtneug/opencast:worker Dockerfiles/worker
.PHONY: build

test check: build
	bats test
.PHONY: test check

clean:
	-docker rmi mtneug/opencast:allinone
	-docker rmi mtneug/opencast:admin
	-docker rmi mtneug/opencast:presentation
	-docker rmi mtneug/opencast:worker
.PHONY: clean