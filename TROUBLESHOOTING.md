# Troubleshooting Scenarios - Interview Prep

## 🎯 Como usar este guia

Em uma entrevista, você pode receber:
- "Seu cluster tá quebrado, por que?" 
- "Esse pod não consegue se comunicar com aquele"
- "O Terraform diz que há conflito de recurso"

Este guia te mostra o pensamento paso-a-paso pra debugar.

---

## 📊 KUBERNETES TROUBLESHOOTING

### Cenário 1: "Pods em CrashLoopBackOff"

**Sintoma:**
```bash
$ kubectl get pods -n production
NAME                    READY   STATUS             RESTARTS   AGE
myapp-5d4cc6d54-abc12   0/1     CrashLoopBackOff   12         5m
```

**O que significa:**
- Pod tá morrer e restartar continuamente
- Algo tá wrong no container ou app

**Seu pensamento na entrevista:**
```
"Ok, CrashLoopBackOff means the container is crashing immediately after starting.
Let me debug this step by step:

1. First, check the logs to see what error happened
2. Then check container image and resources
3. Then check the pod spec itself"
```

**Comando 1 - Ver logs:**
```bash
kubectl logs myapp-5d4cc6d54-abc12 -n production --tail=50

# Se o pod tá restarting, get logs from previous instance:
kubectl logs myapp-5d4cc6d54-abc12 -n production --previous
```

**Possíveis causas + soluções:**

| Causa | Check | Solução |
|-------|-------|---------|
| App exiting com erro | `kubectl logs prev` | Debug app code, check entrypoint |
| Image não existe | `kubectl describe pod` → ImagePullBackOff | Fix image name/tag, check ACR access |
| Resource limit hit | `kubectl top pod` → Memory/CPU maxed | Increase limits or fix memory leak |
| Volume mount permission | `kubectl describe pod` → MountVolume error | Fix PVC, check permissions |
| Readiness probe failing | Logs show healthy app | Remove probe or adjust timeout |

**Your answer:**
```
"First thing I'd do is check the logs:
kubectl logs <pod-name> -n production --previous

If that doesn't show the error, I'd describe the pod:
kubectl describe pod <pod-name> -n production

This shows events and why it couldn't start. Common issues:
- Image pull errors (wrong tag, auth issues)
- Available CPU/memory too low
- Container exiting immediately (app crash)
- Volume mount permission issues

Then I'd check:
kubectl top pod <pod-name> -n production
to see if it's hitting resource limits."
```

---

### Cenário 2: "Pods stuck em Pending"

**Sintoma:**
```bash
$ kubectl get pods -n production
NAME                    READY   STATUS    RESTARTS   AGE
myapp-5d4cc6d54-abc12   0/1     Pending   0          10m
```

**O que significa:**
- Pod foi criado mas não consegue se fazer schedule em nenhum node

**Seu pensamento:**
```
"Pending usually means the scheduler can't find a node 
that matches the pod's requirements.

Could be:
1. Not enough resources on nodes
2. Node selector/affinity não matchando
3. Tolerations faltando
4. PVC doesn't exist"
```

**Comandos de debug:**

```bash
# 1. Check what's holding the pod
kubectl describe pod myapp-5d4cc6d54-abc12 -n production

# Look at "Events" section - says why can't schedule

# 2. Check node availability
kubectl get nodes
kubectl top nodes

# 3. Check pod requirements
kubectl get pod myapp-5d4cc6d54-abc12 -n production -o yaml | grep -A 5 resources

# 4. Check if there's a PVC issue
kubectl get pvc -n production
```

**Possíveis causas + soluções:**

| Causa | Sintom | Solução |
|-------|--------|---------|
| Insufficient CPU | "0/3 nodes available" + "Insufficient cpu" | Scale up cluster or reduce pod limits |
| Insufficient Memory | "0/3 nodes available" + "Insufficient memory" | Scale up nodes or reduce memory requests |
| Node affinity não match | "0 nodes match pod affinity" | Relax affinity rules ou add labels to nodes |
| Taint no node | "0 nodes match pod tolerations" | Add tolerations ou remove taint |
| PVC Pending | "persistentvolumeclaim not found" | Create PVC first |

**Your answer:**
```
"Pending means scheduler couldn't assign it to any node.

First check describe:
kubectl describe pod <pod-name> -n production

The events usually say why. Common reasons:
1. Not enough CPU/memory on any node
2. Node selectors or affinity restrictions
3. PVC doesn't exist
4. Taints on nodes without matching tolerations

I'd check:
- kubectl top nodes → available resources
- kubectl get nodes → check node status
- kubectl get pvc → check if PV exists
- Pod limits → maybe too restrictive"
```

---

### Cenário 3: "Pods podem't communicate com outro pod"

**Sintoma:**
```bash
# Pod A tenta falar com Pod B
$ kubectl exec -it pod-a -n production -- curl pod-b.production.svc.cluster.local:8080
curl: (7) Failed to connect to pod-b.production.svc.cluster.local port 8080: Connection refused
```

**Seu pensamento:**
```
"Connection refused could be several layers:
1. DNS issue - can't resolve hostname
2. Network Policy blocking traffic
3. Pod B not listening on that port
4. Pod B not healthy"
```

**Comandos de debug (em ordem):**

```bash
# 1. Test DNS resolution
kubectl exec -it pod-a -n production -- nslookup pod-b.production.svc.cluster.local

# 2. Check Network Policies
kubectl get networkpolicies -n production
kubectl describe networkpolicy allow-from-ingress -n production

# 3. Check if pod-b is actually running
kubectl get pods -n production | grep pod-b
kubectl logs pod-b -n production

# 4. Check if Pod B is listening
kubectl exec -it pod-b -n production -- netstat -tlnp | grep 8080
# or
kubectl exec -it pod-b -n production -- ss -tlnp | grep 8080

# 5. Test connectivity from pod-b itself
kubectl exec -it pod-b -n production -- curl localhost:8080

# 6. Check service exists
kubectl get svc -n production | grep pod-b
```

**Decision tree:**

```
Pod A → Pod B connection fails?

├─ DNS Resolution fails?
│  └─ Network Policy blocking port 53 (DNS)
│     Fix: Add DNS rule to NetworkPolicy
│
├─ DNS works but connection refused?
│  │
│  ├─ Pod B not running?
│  │  └─ Fix: Check logs, redeploy
│  │
│  ├─ Pod B running but not listening on port?
│  │  └─ Fix: Wrong port in service, or app not listening
│  │
│  └─ Pod B listening but NetworkPolicy blocks it?
│     └─ Fix: Add ingress rule to NetworkPolicy
│
└─ Connection times out?
   └─ Firewall/NSG layer blocking
```

**Your answer:**
```
"Ok, connection refused. Let me think through the layers:

First, check if it's a DNS problem:
kubectl exec -it pod-a -- nslookup pod-b.production.svc.cluster.local

If DNS fails, might be NetworkPolicy blocking port 53 (DNS).

If DNS works, then check if pod-b is actually running and healthy:
kubectl get pods pod-b -n production
kubectl logs pod-b -n production

Then check if pod-b is listening on that port:
kubectl exec -it pod-b -- netstat -tlnp

If it's listening locally but external connection fails, 
it's likely a NetworkPolicy blocking the traffic.

I'd check:
kubectl get networkpolicies -n production
kubectl describe networkpolicy <name>

And verify the rules allow ingress from pod-a to pod-b on port 8080."
```

---

### Cenário 4: "RBAC permission denied"

**Sintoma:**
```bash
$ kubectl exec -it pod-a -n production -- kubectl get secrets
error: Unable to connect to the server: 
  error executing remote command: 
  command terminated with exit code 1
  
Error from server (Forbidden): secrets is forbidden: 
  User "system:serviceaccount:production:app-sa" 
  cannot list resource "secrets" in API group "" 
  in the namespace "production"
```

**Seu pensamento:**
```
"ServiceAccount app-sa doesn't have permission to list secrets.
This is actually GOOD (least privilege).

I need to check:
1. What role is bound to this serviceaccount?
2. Does it include list secrets permission?
3. If not, add the permission or give a different account"
```

**Comandos:**

```bash
# 1. Check what SA the pod is using
kubectl get pod pod-a -n production -o yaml | grep serviceAccountName

# 2. Check the bindings
kubectl get rolebindings -n production
kubectl describe rolebinding app-role-binding -n production

# 3. Check what the role allows
kubectl get roles -n production
kubectl describe role app-role -n production

# 4. Test if the SA can do something
kubectl auth can-i get secrets --as=system:serviceaccount:production:app-sa -n production
kubectl auth can-i list secrets --as=system:serviceaccount:production:app-sa -n production

# Result: yes or no
```

**How to fix:**

```yaml
# If the pod NEEDS to list secrets, update the Role:
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: production
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]  # ← Add list permission
```

**Your answer:**
```
"This is a RBAC permission error. The ServiceAccount app-sa 
doesn't have permission to list secrets.

First, I'd verify what permissions it actually has:
kubectl describe role app-role -n production

If it doesn't include 'list' on secrets, I'd check:
- Does the pod actually NEED to list secrets?
- If yes, update the Role to include that permission
- If no, this is working as intended (least privilege)

I can verify permissions with:
kubectl auth can-i list secrets --as=system:serviceaccount:production:app-sa -n production

This will return 'yes' or 'no'.

If it needs the permission, I'd update the Role to add it."
```

---

## 🔧 TERRAFORM TROUBLESHOOTING

### Cenário 1: "Error: A resource with the ID already exists"

**Sintoma:**
```bash
$ terraform apply
Error: A resource with the ID /subscriptions/.../resourceGroups/aks-rg already exists

  on aks.tf line 15, in resource "azurerm_resource_group" "aks_rg":
   15: resource "azurerm_resource_group" "aks_rg" {
```

**O que significa:**
- Terraform quer criar o resource mas ele já existe no Azure
- Provavelmente alguém criou manualmente ou terraform state tá out of sync

**Seu pensamento:**
```
"This happens when:
1. Resource already exists in Azure but not in .tfstate
2. State file foi deletado ou corrompido
3. Outro job criou o resource

I need to decide:
- Import the resource into state?
- Destroy it manually?
- Use 'terraform refresh'?"
```

**Opções de fix:**

```bash
# Option 1: Refresh state (check current Azure reality)
terraform refresh

# Option 2: Import the existing resource
terraform import azurerm_resource_group.aks_rg /subscriptions/XXX/resourceGroups/aks-rg-production

# Option 3: Destroy it manually in Azure and retry
az group delete --name aks-rg-production

# Option 4: Use target to skip that resource
terraform apply -target=azurerm_kubernetes_cluster.aks_cluster
```

**Your answer:**
```
"This error means the resource exists in Azure but Terraform doesn't know about it.
This typically happens when:
1. Someone created it manually outside Terraform
2. State file got out of sync with reality

I'd first refresh the state to see current reality:
terraform refresh

If that still fails, I can import the existing resource:
terraform import azurerm_resource_group.aks_rg <resource-id>

Or if we don't need it, delete it in Azure and retry terraform apply."
```

---

### Cenário 2: "Error: Insufficient permissions"

**Sintoma:**
```bash
$ terraform apply
Error: Insufficient permissions to perform action

  Authorization failed when attempting to perform operation on resource:
  error message: 'The user, group or application 
  name 'SP' does not have permission to perform 
  action 'Microsoft.ContainerService/managedClusters/write' 
  on scope '/subscriptions/XXX/resourceGroups/aks-rg'"
```

**O que significa:**
- Service Principal/User Account não tem permissões suficientes

**Seu pensamento:**
```
"The Azure identity running terraform doesn't have the right role.
I need to:
1. Check who's running (az account show)
2. Give them the right role in Azure
3. Try again"
```

**Fix:**

```bash
# 1. Check who you are
az account show

# 2. Check current roles
az role assignment list --assignee <object-id>

# 3. Grant the role (Owner or Contributor usually)
az role assignment create \
  --assignee <object-id> \
  --role "Contributor" \
  --scope /subscriptions/<subscription-id>

# 4. Try terraform again
terraform apply
```

**Your answer:**
```
"This is an authentication/authorization issue. 
The identity running Terraform (Service Principal or user) 
doesn't have the right role assignment.

I'd first check who I'm authenticated as:
az account show

Then check their current roles:
az role assignment list --assignee <object-id>

If the required role (like 'Contributor' or specific roles) is missing,
I'd grant it at the subscription or resource group level:
az role assignment create --assignee <id> --role 'Contributor'

Then retry terraform."
```

---

### Cenário 3: "Error: resource_group_name is required"

**Sintoma:**
```bash
$ terraform apply
Error: resource_group_name: required field is missing

  on aks.tf line 68, in resource "azurerm_subnet" "aks_subnet":
   68:   resource_group_name = azurerm_virtual_network.aks_vnet.name  # ← WRONG!
```

**O que significa:**
- Typo na referência de variável ou campo

**Seu pensamento:**
```
"Ok, resource_group_name should reference the Resource Group's name,
not the VNet's name. 

This is a typo in the Terraform code.
Fix it to: azurerm_resource_group.aks_rg.name"
```

**Fix:**

```terraform
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name  # ← CORRECT
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.1.0.0/16"]
}
```

**Your answer:**
```
"This is a simple typo. The resource_group_name is pointing to the wrong resource.

I'd check the Terraform code at that line and verify:
- Is the reference correct?
- Should it be azurerm_resource_group.aks_rg.name?
- Not azurerm_virtual_network.aks_vnet.name

Fix the reference and the error will resolve."
```

---

### Cenário 4: "State lock error"

**Sintoma:**
```bash
$ terraform apply
Error: Error acquiring the lock

Error: Failed to load backend: 
  Error loading Terraform state file: 
  Error locking state error = 
  Error: Acquire lock failed: 
  One or more problems occurred when acquiring lock
```

**O que significa:**
- Alguém tá rodando terraform apply e locked o state
- Ou um job anterior crashou sem liberar o lock

**Seu pensamento:**
```
"State is locked, so nobody else can apply changes.
I need to:
1. See quem tá aplicando
2. Esperar terminar ou forçar liberar o lock
3. Evitar isto usando terraform remote locking"
```

**Opções:**

```bash
# 1. Show who has the lock
terraform state list

# 2. Force unlock (apenas se CERTEZA que ninguém tá rodando!)
terraform force-unlock <LOCK_ID>

# 3. Best practice: use remote backend com auto-locking
# terraform.tf:
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-name"
    storage_account_name = "staccount"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
    # Azure automatically handles locking!
  }
}
```

**Your answer:**
```
"This happens when Terraform can't acquire a lock on the state file.
Usually because another terraform apply is running or crashed.

I'd check if any jobs are currently applying:
- Look at CI/CD pipeline
- Check if any terraform processes are running

If nothing is running, the lock might be stale.
I can force unlock:
terraform force-unlock <lock-id>

But only if I'm 100% sure nobody is actively applying!

Best practice is to use remote backend (Azure Storage)
which has automatic locking/unlocking."
```

---

## 🖥️ LINUX/SHELL TROUBLESHOOTING

### Cenário 1: "kubectl: command not found"

**Sintoma:**
```bash
$ kubectl get pods
kubectl: command not found
```

**Seu pensamento:**
```
"kubectl is not in PATH or not installed.
I need to:
1. Check if it's installed
2. Install it if not
3. Add it to PATH if needed"
```

**Fix:**

```bash
# 1. Check if installed
which kubectl
kubectl version

# 2. If not, install
# On Linux:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 3. Or use Azure CLI
az aks install-cli

# 4. Verify
kubectl version
```

---

### Cenário 2: "Unable to connect to the server"

**Sintoma:**
```bash
$ kubectl get pods
Unable to connect to the server: dial tcp: lookup 
kubernetes.docker.internal on ...: no such host
```

**Seu pensamento:**
```
"kubectl tá tentando conectar em um cluster que não existe no kubeconfig.
I need to:
1. Check kubeconfig
2. Get credentials from AKS cluster
3. Set the context"
```

**Fix:**

```bash
# 1. Check current kubeconfig
kubectl config current-context

# 2. Get credentials from Azure AKS
az aks get-credentials --resource-group aks-rg-production --name aks-cluster

# 3. Check contexts
kubectl config get-contexts

# 4. Switch context if needed
kubectl config use-context aks-cluster

# 5. Verify
kubectl get nodes
```

---

### Cenário 3: "Permission denied" on SSH

**Sintoma:**
```bash
$ ssh -i key.pem azureuser@1.2.3.4
Permission denied (publickey).
```

**Seu pensamento:**
```
"Key permissions issue or wrong user.
Check:
1. Key permissions (should be 0400)
2. Right key for that host?
3. Right user?
4. Host accepting connections?"
```

**Fix:**

```bash
# 1. Check key permissions
ls -la key.pem
chmod 0400 key.pem  # ← Should be this

# 2. Check SSH connectivity
ssh -vvv -i key.pem azureuser@1.2.3.4

# Common issues:
# - Wrong key
# - Wrong user (might be 'admin' or 'ubuntu' not 'azureuser')
# - Host firewall blocking 22
# - NSG not allowing port 22
```

---

## 🧠 GENERAL DEBUGGING MINDSET

When an interviewer asks "Your cluster is broken, what do you do?"

### Your systematic approach:

```
1. UNDERSTAND THE SYMPTOM
   "What's the exact error? When did it start?"

2. NARROW DOWN THE LAYER
   - Infrastructure layer? (VMs, networking, Azure)
   - Kubernetes layer? (pods, services, configmaps)
   - Application layer? (code, logic)

3. GATHER INFORMATION
   kubectl describe <resource>
   kubectl logs <pod>
   kubectl get events
   terraform state
   az ... show

4. FORM HYPOTHESIS
   "I think the issue is X because Y shows Z"

5. TEST HYPOTHESIS
   Run commands to validate or eliminate

6. IMPLEMENT FIX
   Once root cause found, apply solution

7. VERIFY
   Test again to ensure it's fixed
```

### Keywords you should use:

- "Let me investigate..."
- "First, I'd check..."
- "The logs show..."
- "That eliminates the hypothesis that..."
- "So the root cause is..."
- "I'd fix this by..."
- "Let me verify..."

---

## 📋 QUICK REFERENCE - Commands to Know

### Kubernetes Debug Commands:
```bash
kubectl get pods/nodes/svc/pvc -o wide
kubectl describe <resource_type> <name>
kubectl logs <pod> --previous
kubectl exec -it <pod> -- /bin/sh
kubectl top pod/node
kubectl get events --sort-by='.lastTimestamp'
kubectl auth can-i <verb> <resource>
```

### Terraform Debug Commands:
```bash
terraform validate
terraform plan
terraform state list
terraform state show <resource>
terraform import <type>.<name> <id>
terraform refresh
```

### Azure CLI Debug Commands:
```bash
az account show
az group show --name <rg>
az aks show --name <cluster> --resource-group <rg>
az role assignment list
az vm serial-port-connect --resource-group <rg> --name <vm>
```

### Linux Debug Commands:
```bash
ps aux | grep <process>
netstat -tlnp
ss -tlnp
curl -vvv <url>
nslookup <hostname>
ping <host>
traceroute <host>
```

---

## 💡 Interview Tips

1. **Always think out loud**
   - "I think the issue might be X, let me check..."
   - Shows your debugging process

2. **Check logs FIRST**
   - 80% of issues are in logs
   - `kubectl logs <pod> --previous`

3. **Use `-o wide` to see more info**
   - `kubectl get pods -o wide`
   - Shows node, IP, etc

4. **Elimination is your friend**
   - Rule out each layer systematically
   - "OK, it's not DNS (nslookup worked)"
   - "So it must be NetworkPolicy"

5. **If stuck, escalate gracefully**
   - "I'd probably consult documentation..."
   - "I'd check the Azure docs for..."
   - Shows responsibility vs. guessing

6. **Never blame the user (unless they deserve it 😄)**
   - Instead: "Let me verify the permissions..."
   - Professional!

---

**VOCÊ TÁ PRONTO! QUALQUER PERGUNTA QUE VIER, TEM MÉTODO AQUI PRA RESPONDER!** 💪
