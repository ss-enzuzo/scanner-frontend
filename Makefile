IMAGE_NAME    := scanner-frontend
PORT          := 8080
NETWORK       := scanner-net
PROXY_URL     ?= http://8.231.192.24:3000
PROXY_TOKEN   ?= mysecret

GCP_PROJECT   ?= enzuzo-eng
GCP_REGION    ?= us-central1
GAR_REPO      ?= scanner
GAR_IMAGE     ?= frontend
IMAGE_TAG     ?= latest
GAR_PATH       = $(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT)/$(GAR_REPO)/$(GAR_IMAGE):$(IMAGE_TAG)

CLOUD_RUN_SVC := scanner-frontend

.PHONY: install dev build start lint docker-build docker-run docker-stop network clean \
        auth-gar build-prod push build-push gcp-repo gcp-deploy gcp-open gcp-iam help

## Install dependencies
install:
	npm ci

## Start development server
dev:
	npm run dev

## Build the Next.js app
build:
	npm run build

## Start production server
start:
	npm run start

## Run linter
lint:
	npm run lint

## Create Docker network if it doesn't exist
network:
	docker network inspect $(NETWORK) >/dev/null 2>&1 || docker network create $(NETWORK)

## Build local Docker image
docker-build:
	docker build -t $(IMAGE_NAME) .

## Run local Docker image (usage: make docker-run PROXY_URL=... PROXY_TOKEN=...)
docker-run: network
	docker run --rm \
		--name $(IMAGE_NAME) \
		--network $(NETWORK) \
		-p $(PORT):$(PORT) \
		-e PROXY_URL=$(PROXY_URL) \
		-e PROXY_TOKEN=$(PROXY_TOKEN) \
		$(IMAGE_NAME)
	@echo "Running at http://localhost:$(PORT)"

## Stop local Docker container
docker-stop:
	docker stop $(IMAGE_NAME)

## Remove build artifacts and node_modules
clean:
	rm -rf .next node_modules

## Show this help
help:
	@grep -E '^##' $(MAKEFILE_LIST) | sed 's/^## //'

# --- GCP / Cloud Run ---

## Authenticate Docker with Google Artifact Registry
auth-gar:
	gcloud auth configure-docker $(GCP_REGION)-docker.pkg.dev

## Create the Artifact Registry repository
gcp-repo:
	gcloud artifacts repositories create $(GAR_REPO) \
		--repository-format=docker \
		--location=$(GCP_REGION) \
		--project=$(GCP_PROJECT)

## Build production image for linux/amd64 tagged for GAR (usage: make build-prod IMAGE_TAG=v1.2.3)
build-prod:
	docker build --platform linux/amd64 --provenance=false \
		-t $(GAR_PATH) .

## Push image to Google Artifact Registry
push:
	docker push $(GAR_PATH)

## Build and push to Google Artifact Registry
build-push: build-prod push

## Deploy to Cloud Run
gcp-deploy:
	gcloud run deploy $(CLOUD_RUN_SVC) \
		--image $(GAR_PATH) \
		--platform managed \
		--region $(GCP_REGION) \
		--allow-unauthenticated \
		--port $(PORT) \
		--project $(GCP_PROJECT) \
		--set-env-vars PROXY_URL=$(PROXY_URL),PROXY_TOKEN=$(PROXY_TOKEN)

## Open the Cloud Run service URL in a browser
gcp-open:
	gcloud run services describe $(CLOUD_RUN_SVC) \
		--region=$(GCP_REGION) \
		--project=$(GCP_PROJECT) \
		--format='value(status.url)' | xargs open

## Grant public (unauthenticated) access to the Cloud Run service
gcp-iam:
	gcloud run services add-iam-policy-binding $(CLOUD_RUN_SVC) \
		--region=$(GCP_REGION) \
		--member=allUsers \
		--role=roles/run.invoker \
		--project=$(GCP_PROJECT)
