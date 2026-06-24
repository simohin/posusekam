#!/bin/bash
set -e

echo "=== Deploying db-controller ==="

IMAGE_TAG="simohin/posusekam-db-controller:latest"

echo "1. Building and pushing Docker image ($IMAGE_TAG) for amd64..."
docker buildx build --platform linux/amd64 -t $IMAGE_TAG -f db-controller/Dockerfile --push db-controller

echo "2. Deploying via Helm..."
# Используем upgrade --install для бесшовного обновления существующего релиза
helm upgrade --install db-controller ./infra/helm/apps/db-controller

echo "=== Deployment Triggered Successfully ==="
echo "Для просмотра статуса выполни:"
echo "kubectl get pods -l app.kubernetes.io/name=db-controller -w"
