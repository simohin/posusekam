#!/bin/bash
set -e

echo "=== Vault Kubernetes Auth Setup ==="

# Load environment variables
if [ -f .env ]; then
  echo "Loading variables from .env..."
  export $(grep -v '^#' .env | xargs)
fi

VAULT_TOKEN=${VAULT_ROOT_TOKEN:-$VAULT_TOKEN}
if [ -z "$VAULT_TOKEN" ]; then
  echo "Error: VAULT_ROOT_TOKEN or VAULT_TOKEN is not set in .env or environment."
  exit 1
fi

# 1. Enable Kubernetes Auth
echo "1. Enabling kubernetes auth method in Vault..."
kubectl exec -n vault vault-0 -- env VAULT_TOKEN="$VAULT_TOKEN" vault auth enable kubernetes || echo "Auth method 'kubernetes' already enabled."

# 2. Configure Kubernetes Auth
echo "2. Configuring Kubernetes auth method..."
# If vault is running in K8s, it automatically uses its own ServiceAccount token for TokenReview if we don't specify it.
kubectl exec -n vault vault-0 -- env VAULT_TOKEN="$VAULT_TOKEN" sh -c 'vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc:443"'

# 3. Create Policies
echo "3. Creating Policies..."
kubectl exec -n vault vault-0 -- env VAULT_TOKEN="$VAULT_TOKEN" sh -c 'cat <<EOF | vault policy write posusekam-db-read -
path "secret/data/posusekam/database" {
  capabilities = ["read"]
}
EOF'

kubectl exec -n vault vault-0 -- env VAULT_TOKEN="$VAULT_TOKEN" sh -c 'cat <<EOF | vault policy write posusekam-auth-read -
path "secret/data/posusekam/auth-service" {
  capabilities = ["read"]
}
EOF'

# 4. Create Roles
echo "4. Creating Roles..."
kubectl exec -n vault vault-0 -- env VAULT_TOKEN="$VAULT_TOKEN" vault write auth/kubernetes/role/db-migrator \
    bound_service_account_names=db-migrator \
    bound_service_account_namespaces=default \
    policies=posusekam-db-read \
    ttl=1h

kubectl exec -n vault vault-0 -- env VAULT_TOKEN="$VAULT_TOKEN" vault write auth/kubernetes/role/auth-service \
    bound_service_account_names=auth-service \
    bound_service_account_namespaces=default \
    policies=posusekam-auth-read \
    ttl=1h

kubectl exec -n vault vault-0 -- env VAULT_TOKEN="$VAULT_TOKEN" vault write auth/kubernetes/role/backend-service \
    bound_service_account_names=backend-service \
    bound_service_account_namespaces=default \
    policies=posusekam-auth-read \
    ttl=1h

# 5. Write Database Secrets from .env
echo "5. Writing Database Secrets to Vault..."
DB_URL="jdbc:postgresql://${DB_HOST:-192.168.0.106}:${DB_PORT:-5432}/${DB_NAME:-posusekam}"
kubectl exec -n vault vault-0 -- env VAULT_TOKEN="$VAULT_TOKEN" vault kv put secret/posusekam/database \
    url="$DB_URL" \
    username="${DB_USER:-posusekam}" \
    password="${DB_PASSWORD:-47Gumito}"

echo "=== Setup Complete! ==="
