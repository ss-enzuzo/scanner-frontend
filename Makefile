IMAGE_NAME    := scanner-frontend
PORT          := 8080
NETWORK       := scanner-net
PROXY_URL     ?= http://8.231.192.24:3000
PROXY_TOKEN   ?= mysecret

GCP_PROJECT   := enzuzo-eng
GCP_REGION    := us-central1
GCP_REPO      := scanner
GCR_IMAGE     := $(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT)/$(GCP_REPO)/frontend:latest
CLOUD_RUN_SVC := scanner-frontend

.PHONY: install dev build start lint docker-build docker-run docker-stop network clean \
        gcp-auth gcp-repo gcp-push gcp-deploy gcp-open gcp-iam

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

# --- GCP / Cloud Run ---

gcp-auth:
	gcloud auth configure-docker $(GCP_REGION)-docker.pkg.dev

gcp-repo:
	gcloud artifacts repositories create $(GCP_REPO) \
		--repository-format=docker \
		--location=$(GCP_REGION) \
		--project=$(GCP_PROJECT)

gcp-push:
	docker build --platform linux/amd64 -t $(GCR_IMAGE) .
	docker push $(GCR_IMAGE)

gcp-deploy:
	gcloud run deploy $(CLOUD_RUN_SVC) \
		--image $(GCR_IMAGE) \
		--platform managed \
		--region $(GCP_REGION) \
		--allow-unauthenticated \
		--port $(PORT) \
		--project $(GCP_PROJECT) \
		--set-env-vars PROXY_URL=$(PROXY_URL),PROXY_TOKEN=$(PROXY_TOKEN)

gcp-open:
	gcloud run services describe $(CLOUD_RUN_SVC) \
		--region=$(GCP_REGION) \
		--project=$(GCP_PROJECT) \
		--format='value(status.url)' | xargs open

gcp-iam:
	gcloud run services add-iam-policy-binding $(CLOUD_RUN_SVC) \
		--region=$(GCP_REGION) \
		--member=allUsers \
		--role=roles/run.invoker \
		--project=$(GCP_PROJECT)
