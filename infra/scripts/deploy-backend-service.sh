#!/bin/bash
set -e

echo "=== Deploying backend-service ==="

IMAGE_TAG="simohin/posusekam-backend-service:latest"

echo "1. Building and pushing Docker image ($IMAGE_TAG) for amd64..."
docker buildx build --platform linux/amd64 -t $IMAGE_TAG -f backend-service/Dockerfile --push backend-service

echo "2. Deploying via Helm..."
helm upgrade --install backend-service ./infra/helm/apps/backend-service

echo "3. Restarting Deployment to ensure new image pull..."
kubectl rollout restart deployment backend-service

echo "=== Deployment Triggered Successfully ==="
echo "Для просмотра статуса выполни:"
echo "kubectl get pods -l app.kubernetes.io/name=backend-service -w"
