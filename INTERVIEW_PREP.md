# AKS Production Deployment - Interview Prep Guide

## 📋 Overview

Este guia contém tudo que você precisa saber para a entrevista sobre AKS + Terraform.

---

## 1️⃣ TERRAFORM LAYER (aks.tf)

### O que está configurado:

#### **Infrastructure:**
- ✅ **Resource Group** - Container lógico pra tudo
- ✅ **VNet + Subnets** - Dois subnets:
  - AKS subnet: 10.1.0.0/16 (nodes vão aqui)
  - Ingress subnet: 10.2.0.0/16 (Application Gateway)
- ✅ **Network Security Group** - Firewall básico
- ✅ **ACR** - Container registry private
- ✅ **Key Vault** - Secrets management
- ✅ **User Managed Identity** - RBAC com Least Privilege

#### **AKS Cluster:**
```
Nome: aks-cluster
Location: East US
Kubernetes Version: 1.28 (stable)
```

**Node Pool (Padrão):**
- 3 nodes
- VM Size: `Standard_DS2_v2` (2 vCPU, 8GB RAM - bom pra teste/small prod)
- **Availability Zones: 1, 2, 3** ← HA!
- Autoscaling: Min 3, Max 10
- Subnet: aks-subnet (10.1.0.0/16)

**Network:**
- Network Plugin: `azure` (melhor que kubenet)
- **Network Policy: HABILITADA** (azure)
- Service CIDR: 10.10.0.0/16
- DNS: 10.10.0.10

**Addons:**
- ✅ **Azure Policy** - Compliance rules
- ✅ **OMS Agent** - Logging com Azure Monitor
- ✅ **AGIC** - Ingress controller via App Gateway

**Segurança:**
- ✅ RBAC habilitado
- ✅ SystemAssigned Identity
- ✅ NSG com regras
- ✅ Network Policies ativas

---

## 2️⃣ KUBERNETES LAYER (k8s-manifests-prod.yaml)

### O que está configurado (aplicado APÓS cluster criado):

#### **Namespaces:**
```
- production (apps aqui)
- monitoring (prometheus/grafana)
```

#### **Resource Quotas:**
Limita o máximo que pode usar por namespace:
```
Production:
- 100 CPUs max / 200GB RAM max
- 500 pods max

Monitoring:
- 10 CPUs / 20GB RAM
```

**Por quê:** Se um pod fica louco (memory leak), não mata o cluster inteiro.

#### **Network Policies:**
Três camadas:

1. **Deny All** - Default: rejeita tráfego que não está explicitamente permitido
2. **Allow Specific** - Permite apenas:
   - Do ingress controller
   - Pod-to-pod no mesmo namespace
   - DNS (UDP/TCP 53)
3. **Egress Rules** - O que sai:
   - DNS allowed
   - HTTPS allowed (porta 443)
   - Bloqueia metadata service (169.254.169.254)

**Por quê:** Zero Trust. Se um pod é compromisado, ataques ficam limitados.

#### **Pod Security:**
```yaml
- No root user (runAsUser: 1000)
- Read-only filesystem
- Sem privilégios
- Resource limits por pod
- Health checks (liveness/readiness)
```

#### **RBAC:**
- ServiceAccount `app-sa`
- Role com permissões mínimas (só get/list de ConfigMaps e Secrets)
- RoleBinding conectando os dois

**Por quê Least Privilege:** 
- Se pod é compromisado, só pode fazer o que a role permite
- Não pode criar/delete deployments, etc

#### **Pod Disruption Budget (PDB):**
```
minAvailable: 2
```
= Garante que sempre tem pelo menos 2 pods rodando (pra updates/maintenance)

---

## 3️⃣ RESPOSTAS MODELO PARA ENTREVISTA

### **Pergunta 1: "Design an AKS cluster for production"**

**Resposta:**
```
"Okay, so for production, I would think about several layers:

INFRASTRUCTURE LAYER (Terraform):
1. First, I'd set up a Resource Group and VNet with multiple subnets
   - One for AKS nodes
   - One for ingress/load balancing
   
2. For HIGH AVAILABILITY, I'd spread nodes across Availability Zones 
   - Using zones 1, 2, 3. That way if one AZ fails, we're still running.
   
3. Three nodes initially with Standard_DS2_v2 SKU
   - That's a good starting point (2vCPU, 8GB RAM)
   - Enable cluster autoscaling (min 3, max 10)
   
4. For SECURITY:
   - Use Azure managed identity (UserAssigned)
   - RBAC enabled
   - Network Policies at the cluster level (azure plugin)
   - Azure Policy addon for compliance
   - Network Security Groups
   
5. For CONNECTIVITY:
   - ACR (private container registry)
   - Application Gateway with AGIC for ingress
   - Key Vault for secrets
   
6. MONITORING:
   - Azure Monitor with OMS Agent
   - Log Analytics workspace

KUBERNETES LAYER (manifests applied after):
1. Resource Quotas per namespace - prevents starvation
2. Network Policies (deny-all by default, allow specific traffic)
3. Pod Security Standards (no root, read-only FS, etc)
4. RBAC with ServiceAccounts and minimal roles
5. Pod Disruption Budgets for HA during updates

So basically... infrastructure as code (Terraform) for the cloud resources,
then Kubernetes manifests for pod-level policies and security."
```

### **Pergunta 2: "Why Availability Zones?"**

**Resposta:**
```
"If we're in a single AZ and that datacenter goes down, 
the entire cluster is offline. 

By spreading nodes across 3 AZs, we guarantee that 
even if one fails, we still have 2 running. 
It's basically geographic redundancy within the same region."
```

### **Pergunta 3: "What's Network Policy vs NSG?"**

**Resposta:**
```
"Good question. They work at different layers:

NSG (Network Security Group) - INFRA LEVEL:
- Controls traffic between subnets and VMs
- Firewall at Azure level
- In my config, I use it to allow Kubelet API (port 10250)

Network Policy - KUBERNETES LEVEL:
- Controls pod-to-pod communication
- More granular than NSG
- I configure 'deny all' by default, then whitelist specific traffic
- Protects against lateral movement if a pod is compromised"
```

### **Pergunta 4: "Explain Resource Quotas"**

**Resposta:**
```
"Resource Quotas prevent a single namespace from consuming all cluster resources.

For example, if a pod has a memory leak and keeps allocating RAM,
without quotas it could crash the entire cluster.

With quotas set, I limit:
- Max CPUs per namespace (100 for production)
- Max memory (200GB)
- Max pods (500)

This way, even if an app goes crazy, other apps keep running."
```

### **Pergunta 5: "What about RBAC? Least Privilege?"**

**Resposta:**
```
"Least Privilege means: give every app only the MINIMUM permissions it needs.

In my setup:
1. Each app gets its own ServiceAccount (identity)
2. ServiceAccount is bound to a Role with specific permissions
3. Role only allows: 
   - GET/LIST ConfigMaps and Secrets (read-only)
   - GET/LIST Deployments

So if that pod is compromised, attacker can't:
- Delete deployments
- Create new pods
- Access secrets (just list that they exist)
- Modify anything

They're stuck with read-only permissions for specific resources."
```

### **Pergunta 6: "How would you troubleshoot if pods can't reach each other?"**

**Resposta:**
```
"Good question. I'd check in order:

1. Network Policies: Are they blocking traffic?
   - Check 'kubectl get networkpolicies'
   - Verify ingress/egress rules

2. DNS: Can pods resolve each other?
   - Test: kubectl exec -it pod -- nslookup service-name.namespace
   
3. NSG: Are Azure-level rules blocking?
   - Check security rules in that subnet

4. Connectivity: Pod to pod network
   - Ping tests, port checks

Usually, my first suspect is Network Policy denying traffic
(because I default to deny-all, whitelist specific).

Second would be DNS or pod not running (Ready state)."
```

---

## 4️⃣ ARQUITETURA VISUAL

```
┌─────────────────────────────────────────────────┐
│             Azure Subscription                  │
│  ┌─────────────────────────────────────────┐   │
│  │         Resource Group                  │   │
│  │  ┌─────────────────────────────────┐    │   │
│  │  │      VNet (10.0.0.0/8)          │    │   │
│  │  │  ┌──────────────┬──────────┐    │    │   │
│  │  │  │  AKS Subnet  │ Ingress  │    │    │   │
│  │  │  │  (10.1)      │ Subnet   │    │    │   │
│  │  │  │              │ (10.2)   │    │    │   │
│  │  │  │  ┌─┬─┬─┐     │          │    │    │   │
│  │  │  │  │1│2│3│ NSG │ AppGW   │    │    │   │
│  │  │  │  │ │ │ │     │          │    │    │   │
│  │  │  │  └─┴─┴─┘     │          │    │    │   │
│  │  │  └──────────────┴──────────┘    │    │   │
│  │  │                                  │    │   │
│  │  │    Network Policies (K8s)        │    │   │
│  │  │    ├─ Deny All (default)         │    │   │
│  │  │    ├─ Allow Ingress Controller   │    │   │
│  │  │    └─ Allow DNS                  │    │   │
│  │  │                                  │    │   │
│  │  │    Resource Quotas (K8s)         │    │   │
│  │  │    ├─ 100 CPUs max               │    │   │
│  │  │    ├─ 200GB RAM max              │    │   │
│  │  │    └─ 500 pods max               │    │   │
│  │  └─────────────────────────────────┘    │   │
│  │                                          │   │
│  │  ├─ ACR (Registry)                      │   │
│  │  ├─ Key Vault (Secrets)                 │   │
│  │  ├─ Log Analytics (Monitoring)          │   │
│  │  └─ Managed Identity (RBAC)             │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘

Availability Zones: 1, 2, 3 (3 nodes distributed)
```

---

## 5️⃣ COMANDOS ÚTEIS (pra praticar)

### Deploy:
```bash
# Validate Terraform
terraform plan

# Apply
terraform apply

# Get kubeconfig
az aks get-credentials --resource-group <rg> --name <cluster>

# Apply K8s manifests
kubectl apply -f k8s-manifests-prod.yaml
```

### Troubleshoot:
```bash
# Check Resource Quotas
kubectl get resourcequota -n production

# Check Network Policies
kubectl get networkpolicies -n production

# Check pod getting created?
kubectl get pods -n production

# Check service account
kubectl get sa -n production

# RBAC check
kubectl auth can-i get secrets --as=system:serviceaccount:production:app-sa -n production

# Check node distribution
kubectl get nodes -o custom-columns=NAME:.metadata.name,ZONE:.metadata.labels.topology\.kubernetes\.io/zone
```

---

## 6️⃣ KEYWORDS IMPORTANTES

- **HA (High Availability)** - Spread across AZs
- **Least Privilege** - Minimal RBAC permissions
- **Defense in Depth** - Multiple layers (NSG, Network Policy, RBAC)
- **Zero Trust** - Deny by default, allow specific
- **Idempotent** - Terraform = reproducible
- **GitOps** - Version control everything
- **Observability** - Logging, monitoring, alerting

---

## 7️⃣ POSSÍVEL FOLLOW-UP QUESTIONS

### "How would you handle secrets?"
→ Key Vault + pod mounted volumes, não hardcoded

### "What about disaster recovery?"
→ Backup via Velero, Azure Site Recovery, multi-region

### "How do you do updates?"
→ Rolling deployments, drain nodes gracefully, PodDisruptionBudgets

### "Cost optimization?"
→ Reserved instances, spot VMs, autoscaling, cleanup unused resources

### "CI/CD integration?"
→ Azure DevOps, GitHub Actions, push images to ACR

---

**BOA SORTE NA ENTREVISTA! TÊ ARRASANDO! 💪**
