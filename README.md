# Foundation Platform (nas-k8s-foundation)

This repository defines the core platform services and the GitOps management layer for the home Kubernetes cluster.

## Architecture

We use the **App of Apps** pattern with Argo CD to manage the cluster.

- `argocd/applications/root-app.yaml`: The entry point. It watches `argocd/applications/` and deploys every manifest found there.
- `argocd/projects/`: Defines logical groupings and security boundaries for applications.
- `base/`: Raw Kubernetes manifests or Kustomize bases for platform services (Traefik, Prometheus, etc.).
- `environments/`: Environment-specific overlays (prod/dev).

## GitOps Flow

1. **Bootstrap**: 
   - Apply `argocd/bootstrap/install.yaml` manually to the cluster.
   - Apply `argocd/applications/root-app.yaml`.
2. **Synchronization**:
   - Argo CD detects `root-app`.
   - `root-app` syncs `ingress.yaml`, `monitoring.yaml`, etc.
   - Each individual app syncs its respective path in `base/`.

## Configuration Management

We use a central `.env` file to manage cluster-wide variables (like `STORAGE_CLASS`). To keep your Helm values in sync with your `.env` settings:

1. Update the variables in `.env`.
2. Run `./sync.sh` in the root of `nas-k8s-foundation`.
3. Commit and push the changes.

This ensures that cluster-wide policies (like Kyverno storage injection) always match your environment settings.

## Naming Conventions

### Namespaces
- `argocd`: GitOps engine.
- `network-system`: Ingress controllers, cert-manager, Cloudflare.
- `monitoring-system`: Prometheus, Grafana, Loki.
- `storage-system`: NFS Provisioner, Longhorn (if used).
- `security-system`: Sealed Secrets, Vault.

### Domain Strategy
- **Internal**: `service.cluster.local`
- **External (Cloudflare)**: `app.yourdomain.com`
- **Traefik Middlewares**: Used for AuthN/AuthZ (e.g., ForwardAuth with Authelia/Authentik).
