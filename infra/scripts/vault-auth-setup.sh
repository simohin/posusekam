#!/bin/bash
set -e

echo "=== Vault Kubernetes Auth Setup ==="

# 1. Enable Kubernetes Auth
echo "1. Enabling kubernetes auth method in Vault..."
kubectl exec -n vault vault-0 -- vault auth enable kubernetes || echo "Auth method 'kubernetes' already enabled."

# 2. Configure Kubernetes Auth
echo "2. Configuring Kubernetes auth method..."
# If vault is running in K8s, it automatically uses its own ServiceAccount token for TokenReview if we don't specify it.
kubectl exec -n vault vault-0 -- sh -c 'vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc:443"'

# 3. Create Policy
echo "3. Creating Policy 'posusekam-db-read'..."
kubectl exec -n vault vault-0 -- sh -c 'cat <<EOF | vault policy write posusekam-db-read -
path "secret/data/posusekam/database" {
  capabilities = ["read"]
}
EOF'

# 4. Create Role
echo "4. Creating Role 'db-migrator'..."
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/db-migrator \
    bound_service_account_names=db-migrator \
    bound_service_account_namespaces=default \
    policies=posusekam-db-read \
    ttl=1h

echo "=== Setup Complete! ==="
