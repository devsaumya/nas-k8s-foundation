# 🏥 Platform Recovery & Disaster Runbook

This guide provides step-by-step instructions for recovering from major failures in the Enterprise Home Cloud.

---

## 🚨 Incident 1: NAS Power Failure / Hardware Loss
**Symptoms**: All storage is unavailable. K3s Master is down.

### 🛠️ Recovery Steps:
1.  **Boot the N100**: If only the NAS is down, the N100 can still run some workloads.
2.  **Restore K3s Master**:
    ```bash
    cd nas-infra-provisioning
    ansible-playbook -i ... install-k3s-master.yml
    ```
3.  **Mount Backups**: Use **Velero** to restore the latest snapshot from Cloudflare R2:
    ```bash
    velero restore create --from-backup manual-latest
    ```

---

## 🚨 Incident 2: Database Corruption (Postgres-HA)
**Symptoms**: App shows `500 Error` or `Database Connection Failed`.

### 🛠️ Recovery Steps:
1.  **Check HA Status**:
    ```bash
    kubectl get clusters.postgresql.cnpg.io -n data
    ```
2.  **Trigger Switchover**: If the primary is stuck, promote a replica:
    ```bash
    kubectl cnpg promote postgres-ha -n data
    ```
3.  **Point-in-Time Recovery**: If data is deleted, use Velero to restore to a specific time.

---

## 🚨 Incident 3: Cloudflare Tunnel Disconnect
**Symptoms**: Public URLs return `502` or `Connection Timed Out`.

### 🛠️ Recovery Steps:
1.  **Check Tunnel Pod**:
    ```bash
    kubectl logs -l app=cloudflared -n network-system
    ```
2.  **Restart Agent**:
    ```bash
    kubectl rollout restart deployment cloudflared -n network-system
    ```
3.  **Local Access**: Use the **Tailscale VPN** to access the dashboards directly via internal IPs.

---

## 🛡️ Weekly Maintenance Checklist
- [ ] Run `ansible-playbook ... maintenance.yml`.
- [ ] Run `ansible-playbook ... dr-drill.yml` (Verify R2 backup).
- [ ] Check **Trivy** security reports in Backstage.
- [ ] Review **SLOs** in Grafana.
