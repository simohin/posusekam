#!/bin/bash
set -e

echo "=== Deploying auth-service ==="

IMAGE_TAG="simohin/posusekam-auth-service:latest"

echo "1. Building and pushing Docker image ($IMAGE_TAG) for amd64..."
docker buildx build --platform linux/amd64 -t $IMAGE_TAG -f auth-service/Dockerfile --push auth-service

echo "2. Deploying via Helm..."
helm upgrade --install auth-service ./infra/helm/apps/auth-service

echo "3. Restarting Deployment to ensure new image pull..."
kubectl rollout restart deployment auth-service

echo "=== Deployment Triggered Successfully ==="
echo "Для просмотра статуса выполни:"
echo "kubectl get pods -l app.kubernetes.io/name=auth-service -w"
