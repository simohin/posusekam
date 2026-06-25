#!/bin/bash
set -e

echo "=== Deploying backend-service ==="

IMAGE_TAG="simohin/posusekam-backend-service:latest"

echo "1. Building and pushing Docker image ($IMAGE_TAG) for amd64..."
docker buildx build --platform linux/amd64 -t $IMAGE_TAG -f backend-service/Dockerfile --push backend-service

echo "2. Deploying via Helm..."

# Load database settings from .env
if [ -f .env ]; then
  echo "Loading DB settings from .env..."
  export $(grep -v '^#' .env | xargs)
fi

DB_URL="jdbc:postgresql://${DB_HOST:-192.168.0.106}:${DB_PORT:-5432}/${DB_NAME:-posusekam}"
DB_USER="${DB_USER:-posusekam}"
DB_PASSWORD="${DB_PASSWORD:-47Gumito}"

helm upgrade --install backend-service ./infra/helm/apps/backend-service \
  --set database.url="$DB_URL" \
  --set database.username="$DB_USER" \
  --set database.password="$DB_PASSWORD"

echo "3. Restarting Deployment to ensure new image pull..."
kubectl rollout restart deployment backend-service

echo "=== Deployment Triggered Successfully ==="
echo "Для просмотра статуса выполни:"
echo "kubectl get pods -l app.kubernetes.io/name=backend-service -w"
