# 🏗️ Enterprise Home Cloud Platform

Welcome to the **Enterprise Home Cloud**, a production-grade GitOps platform designed for headless Ubuntu Server environments (NAS + N100 Node). 

---

## 🏆 Final Project Achievements

I have successfully completed the **Enterprise-Grade Transformation** of this platform. We have moved from basic automation to a **Hybrid-Cloud GitOps Ecosystem** that follows the same standards as a "Tier 1" tech company.

*   **Hybrid-Cloud Architecture**: Your cluster now spans from your **Home (NAS/N100)** to the **Public Cloud (Oracle ARM)** via a secure **Tailscale VPN**.
*   **Zero-Trust Security**: Every dashboard is protected by **Cloudflare Access** and **Authelia SSO**, with **Linkerd mTLS** encrypting all internal traffic.
*   **Resilient Data & Logging**:
    *   **3-2-1 Backups**: Local MinIO + Offsite **Cloudflare R2**.
    *   **Disaster Forensics**: Offsite log mirroring to **Axiom (0.5TB Free)**.
    *   **Managed DB**: Critical metadata stored in **MongoDB Atlas**.
*   **Edge Defense**: **Cloudflare Workers** act as your programmable firewall at the network edge.
*   **Professional Developer Experience**: **Backstage.io** portal for service tracking and **Liquibase** for automated database migrations.

---

## 🗺️ System Architecture

```mermaid
flowchart TB

%% =========================
%% GitOps Workflow
%% =========================
Dev[Developer] --> GitHub[GitHub Repositories]
GitHub --> Actions[GitHub Actions / Ansible Master Deploy]
Actions --> ArgoCD[Argo CD (Kubara GitOps Controller)]
ArgoCD --> Cluster[Kubernetes Cluster (k3s)]

%% =========================
%% NAS - CONTROL PLANE
%% =========================
subgraph NAS["NAS (Control Plane + Storage + GitOps)"]

    subgraph ControlPlane["Kubara Control Plane"]
        K3sMaster[k3s Server<br/>API / Scheduler / etcd]
        ArgoCD
        Traefik[Traefik Ingress]
        Authelia[Authelia SSO]
        LLDAP[LLDAP Identity]
        Linkerd[Linkerd mTLS Mesh]
        CertManager[Cert Manager]
        ESO[External Secrets<br/>(Bitwarden)]
        Kyverno[Policy Engine]
        Prometheus[Prometheus]
        Grafana[Grafana]
        Loki[Loki Logging]
        Tempo[Tempo Tracing]
        Velero[Velero Backup]
    end

    subgraph Storage["Storage Layer"]
        NFS[NFS Server (20TB)]
        MinIO[MinIO (S3 Backup)]
    end
end

%% =========================
%% N100 WORKER NODE
%% =========================
subgraph N100["N100 Mini PC (Runtime Workloads)"]

    subgraph Workloads["Workloads (Namespaces)"]

        Backstage[Backstage Developer Portal]
        API[APIs / Services]
        Immich[Immich (Media)]
        
        Postgres[Postgres HA (CloudNativePG)]
        Redis[Redis HA (Sentinel)]
        Migration[Liquibase Migration Jobs]

    end

    subgraph Data["Persistent Storage (PVC via NFS)"]
        PVC1[App PVC]
        PVC2[DB PVC]
        PVC3[Media PVC]
    end
end

%% =========================
%% HYBRID CLOUD
%% =========================
subgraph Cloud["Hybrid Cloud Layer"]

    Oracle[Oracle ARM Node]
    Mongo[MongoDB Atlas]
    Axiom[Axiom Logs]
    R2[Cloudflare R2 Backup]

end

%% =========================
%% ACCESS LAYER
%% =========================
subgraph Access["Zero Trust Access"]

    CF[Cloudflare Tunnel]
    Workers[Cloudflare Workers Firewall]
    Tailscale[Tailscale VPN Mesh]

end

%% =========================
%% CONNECTIONS
%% =========================

%% GitOps
ArgoCD --> NAS
ArgoCD --> N100

%% Storage
N100 --> NFS
Velero --> MinIO
MinIO --> R2

%% Logs
N100 --> Loki
Loki --> Axiom

%% DB External
API --> Mongo

%% Access Flow
Users[Users] --> CF
CF --> Workers
Workers --> Traefik
Traefik --> Authelia
Authelia --> Workloads

%% VPN Mesh
NAS --> Tailscale
N100 --> Tailscale
Oracle --> Tailscale

%% Secrets Flow
ESO --> Workloads

%% Observability
Prometheus --> Grafana
Tempo --> Grafana
```

> [!TIP]
> View the high-resolution static diagram here: [architecture.png](./docs/assets/architecture.png)

---

## 🏁 The "Always Free" Architecture

This platform is resilient against home hardware failure, power outages, and targeted edge attacks—all for **$0/month** by leveraging the best of the 2026 Free-for-Dev ecosystem.

| Component | Provider | Free Tier Value | Status |
| :--- | :--- | :--- | :--- |
| **Compute** | Oracle Cloud | 4 OCPUs, 24GB RAM, 200GB SSD | ✅ Always Free |
| **VPN** | Tailscale | 100 Devices, 3 Users | ✅ Free Personal |
| **Logs** | Axiom | 0.5 TB (500 GB) / Month | ✅ Free Forever |
| **Backups** | Cloudflare R2 | 10 GB Storage, Zero Egress | ✅ Free Tier |
| **Database** | MongoDB Atlas | Shared Cluster (M0) | ✅ Always Free |
| **Security** | Cloudflare | Zero Trust (50 Users), WAF | ✅ Free Plan |

---

## 🛠️ Service Catalog (Tech Stack)

| Service | Category | What it does |
| :--- | :--- | :--- |
| **Argo CD** | GitOps / CD | The "Brain" that syncs your Git repositories to the Kubernetes cluster. |
| **Bitwarden BWS** | Secrets | The "Vault" where all your sensitive passwords and tokens are stored. |
| **External Secrets**| Security | Automatically pulls secrets from Bitwarden into your Kubernetes Pods. |
| **Linkerd** | Service Mesh | Provides mTLS encryption between all apps and deep traffic visibility. |
| **Kyverno** | Policy | Enforces cluster rules (e.g., automatically injecting storage settings). |
| **Trivy** | Security | Continuously scans your running containers for security vulnerabilities. |
| **Prometheus** | Monitoring | Collects metrics and performance data from your nodes and apps. |
| **Grafana** | Visualization | The dashboard UI for viewing your cluster health and security reports. |
| **Loki** | Logging | Aggregates all your application logs into a single searchable window. |
| **Tempo** | Tracing | Provides distributed tracing to track requests as they travel between apps. |
| **Velero** | Backup / DR | Performs cluster-wide backups and restores to your NAS (MinIO). |
| **Cert-Manager** | SSL / TLS | Automatically handles Let's Encrypt certificates for all your domains. |
| **Traefik** | Ingress | The reverse proxy that routes internet traffic to your internal apps. |
| **Multus CNI** | Networking | Enables MACVLAN support so Pods can have their own physical IP. |
| **MinIO** | S3 Storage | Provides high-performance object storage for backups and data. |
| **faasd** | Serverless | A lightweight environment for running lambda-style functions. |
| **Authelia** | Identity | The Single Sign-On (SSO) portal for unified login. |
| **LLDAP** | Identity | Lightweight LDAP server for managing your users and groups. |
| **Backstage** | Developer Portal| The "Nerve Center" for tracking all your services and documentation. |
| **Tailscale** | VPN / Mesh | Securely connects your home servers and cloud nodes into one network. |
| **Axiom** | Logging | Offsite "Flight Recorder" for log storage with 0.5TB free monthly. |
| **MongoDB Atlas** | Database | Managed cloud database for critical metadata and application data. |

---

## 🚀 Absolute Deployment Sequence (Where & What)

Follow this numbered sequence exactly. Do not skip steps.

### Step 1: Initialize Infrastructure
**📁 Directory**: `cd ../nas-infra-provisioning`

1.  **⚙️ Config**: Edit `ansible/inventory/prod.ini` (Set NAS and N100 IPs).
2.  **✅ Command**: Install K3s & OS Base:
    ```bash
    ansible-playbook -i ansible/inventory/prod.ini ansible/playbooks/install-k3s-master.yml
    ansible-playbook -i ansible/inventory/prod.ini ansible/playbooks/install-k3s-worker.yml
    ```

### Step 2: Provision NAS Services
**📁 Directory**: `cd ../nas-infra-provisioning`

1.  **✅ Command**: Setup Docker, MinIO, and faasd:
    ```bash
    ansible-playbook -i ansible/inventory/prod.ini ansible/playbooks/setup-minio.yml
    ansible-playbook -i ansible/inventory/prod.ini ansible/playbooks/setup-faasd.yml
    ```

### Step 3: Bootstrap Secrets & Argo CD
**📁 Directory**: `cd ../nas-infra-provisioning`

1.  **⚙️ Config**: Ensure `.env` is filled out.
2.  **✅ Command**: Inject Bitwarden Master Token:
    ```bash
    export BWS_ACCESS_TOKEN="your-bws-token-here"
    ansible-playbook -i ansible/inventory/prod.ini ansible/playbooks/setup-secrets.yml
    ```
3.  **✅ Command**: Install Argo CD Controller:
    ```bash
    kubectl apply -k ./managed-service-catalog/argo-cd/
    ```

### Step 4: The "Master" Deploy (Final Rollout)
**📁 Directory**: `cd ../nas-infra-provisioning`

1.  **✅ Command**: This runs the global sync, pushes all repos to Git, and triggers Argo CD:
    ```bash
    ansible-playbook -i ansible/inventory/prod.ini ansible/playbooks/master-deploy.yml
    ```

---

## 🛠️ Operational Commands (Day 2)

| Task | Where | Command |
| :--- | :--- | :--- |
| **Check Health** | `nas-infra-provisioning` | `ansible-playbook -i ... health-check.yml` |
| **System Update**| `nas-infra-provisioning` | `ansible-playbook -i ... maintenance.yml` |
| **Backup Drill** | `nas-infra-provisioning` | `ansible-playbook -i ... dr-drill.yml` |
| **DB Migration** | `nas-infra-provisioning` | `ansible-playbook -i ... run-migration.yml` |
| **VPN Setup** | `nas-infra-provisioning` | `ansible-playbook -i ... setup-tailscale.yml` |
| **Cloud Node** | `nas-infra-provisioning` | `ansible-playbook -i ... setup-oracle-node.yml` |
| **DR Runbook** | `nas-k8s-foundation` | [RECOVERY_RUNBOOK.md](./docs/RECOVERY_RUNBOOK.md) |

---

## 📂 Repository Responsibilities

- **../nas-infra-provisioning**: Bare metal, K3s, Docker, and Ansible Automation.
- **.**: Argo CD, External Secrets, Linkerd, and Monitoring.
- **../n100-services-runtime**: Your Applications (Nextcloud, Immich, Postgres-HA).

---

## 📊 Quick Access URLs
- **GitOps**: `https://home.<yourdomain>/argocd`
- **DNS**: `http://192.168.1.53` (AdGuard)
- **Monitoring**: `https://home.<yourdomain>/grafana`
- **S3 Storage**: `http://192.168.1.10:9001` (MinIO)
