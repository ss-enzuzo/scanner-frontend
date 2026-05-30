IMAGE_NAME    := scanner-frontend
PORT          := 8080
NETWORK       := scanner-net
PROXY_URL     ?= http://scanner-proxy:3000
PROXY_TOKEN   ?= mysecret

.PHONY: install dev build start lint docker-build docker-run docker-stop network clean

install:
	npm ci

dev:
	npm run dev

build:
	npm run build

start:
	npm run start

lint:
	npm run lint

network:
	docker network inspect $(NETWORK) >/dev/null 2>&1 || docker network create $(NETWORK)

docker-build:
	docker build -t $(IMAGE_NAME) .

docker-run: network
	docker run --rm \
		--name $(IMAGE_NAME) \
		--network $(NETWORK) \
		-p $(PORT):$(PORT) \
		-e PROXY_URL=$(PROXY_URL) \
		-e PROXY_TOKEN=$(PROXY_TOKEN) \
		$(IMAGE_NAME)
	@echo "Running at http://localhost:$(PORT)"

docker-stop:
	docker stop $(IMAGE_NAME)

clean:
	rm -rf .next node_modules
