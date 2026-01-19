APP_NAME := demo-api
IMAGE_NAME ?= ghcr.io/confused-coder1919/outsight-platform-devops-demo/demo-api
TAG ?= dev

.PHONY: lint test run docker-build docker-run k3d argocd observability gitops

lint:
	ruff check .

test:
	pytest -q

run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

docker-build:
	docker build -t $(IMAGE_NAME):$(TAG) .

docker-run:
	docker run --rm -p 8000:8000 -e TENANT_NAME=local $(IMAGE_NAME):$(TAG)

k3d:
	./scripts/bootstrap_k3d.sh

argocd:
	./scripts/install_argocd.sh

observability:
	./scripts/install_observability.sh

gitops:
	./scripts/deploy_gitops.sh
