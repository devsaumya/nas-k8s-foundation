#!/bin/bash

# --- Configuration ---
ENV_FILE=".env"
# Find all values.yaml files in both repos
VALUES_FILES=$(find . ../n100-services-runtime -name "values.yaml" 2>/dev/null)

# Ensure we are in the right directory
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found. Please run this script from the nas-k8s-foundation directory."
    exit 1
fi

# 1. Load variables from .env
STORAGE_CLASS=$(grep "^STORAGE_CLASS=" "$ENV_FILE" | cut -d'=' -f2)
BITWARDEN_ORG_ID=$(grep "^BITWARDEN_ORG_ID=" "$ENV_FILE" | cut -d'=' -f2)
BITWARDEN_ACCESS_TOKEN=$(grep "^BITWARDEN_ACCESS_TOKEN=" "$ENV_FILE" | cut -d'=' -f2)
DOMAIN_NAME=$(grep "^DOMAIN_NAME=" "$ENV_FILE" | cut -d'=' -f2)

echo "🔄 Syncing configuration from .env to all Helm values..."

for file in $VALUES_FILES; do
    # 2. Update Storage Class
    if [ ! -z "$STORAGE_CLASS" ]; then
        if [[ "$file" == *"kyverno-policies/values.yaml"* ]]; then
            # This is the source of truth for the policy
            echo "  -> Setting Global Storage Target to '$STORAGE_CLASS' in $file"
            sed -i '' "s|storageClass:.*|storageClass: \"$STORAGE_CLASS\"|g" "$file"
        else
            # All other apps should point to 'default' to be intercepted by Kyverno
            if grep -q "storageClass:" "$file" || grep -q "storageClassName:" "$file"; then
                echo "  -> Standardizing app to 'default' storage in $file"
                sed -i '' "s|storageClass:.*|storageClass: \"default\"|g" "$file"
                sed -i '' "s|storageClassName:.*|storageClassName: \"default\"|g" "$file"
            fi
        fi
    fi

    # 3. Update Domain Name
    if [ ! -z "$DOMAIN_NAME" ] && [ "$DOMAIN_NAME" != "yourdomain.com" ]; then
        if grep -q "yourdomain.com" "$file"; then
            echo "  -> Updating Domain Name in $file"
            sed -i '' "s|yourdomain.com|$DOMAIN_NAME|g" "$file"
        fi
    fi

    # 4. Update Bitwarden Org ID
    if [[ "$file" == *"external-secrets/values.yaml"* ]] && [ ! -z "$BITWARDEN_ORG_ID" ] && [ "$BITWARDEN_ORG_ID" != "your-org-id-here" ]; then
        echo "  -> Setting BITWARDEN_ORG_ID in $file"
        sed -i '' "s|organizationID:.*|organizationID: \"$BITWARDEN_ORG_ID\"|g" "$file"
    fi
done

# 5. Check for Bitwarden Secrets Manager CLI
if command -v bws &> /dev/null && [ ! -z "$BITWARDEN_ACCESS_TOKEN" ] && [ "$BITWARDEN_ACCESS_TOKEN" != "your-access-token-here" ]; then
    echo "🔐 Bitwarden CLI (bws) detected. Syncing secrets..."
    export BWS_ACCESS_TOKEN="$BITWARDEN_ACCESS_TOKEN"
else
    echo "⚠️  Bitwarden CLI (bws) not found or token not set. Skipping sensitive token sync."
fi

echo "✅ Sync complete."
