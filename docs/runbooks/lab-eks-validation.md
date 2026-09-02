# EKS Lab Validation

## Purpose

This runbook validates the minimal EKS foundation after Terraform create or
update operations and establishes a known-good baseline before application
workloads, observability components, autoscaling, or reliability experiments are
introduced.

Current lab target:

- Cluster: `infra-iac-lab-eks`
- Region: `us-east-1`
- Kubernetes version: `1.36`
- Managed Node Group: `infra-iac-lab-eks-default`
- Desired nodes: `2`
- Instance type: `t3.small`
- Worker placement: private subnets across `us-east-1a` and `us-east-1b`
- Human access role: `arn:aws:iam::978121310268:role/eks-lab-admin`
- Terraform root: `environments/lab-eks`

## Preconditions

- AWS CLI is authenticated for the target AWS account.
- `kubectl` is installed.
- Terraform is installed.
- Kubeconfig is configured using the `eks-lab-admin` role.
- Do not record MFA tokens, temporary credentials, secrets, AWS session tokens,
  or generated EKS API endpoint values in this document.

Configure kubeconfig:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name infra-iac-lab-eks \
  --role-arn arn:aws:iam::978121310268:role/eks-lab-admin
```

The `eks-lab-admin` role requires MFA. If `AssumeRole` fails because MFA is
missing or invalid, fix the MFA flow; do not bypass the MFA requirement.

## 1. Validate Kubernetes API Connectivity

```bash
kubectl cluster-info
```

Expected:

- The Kubernetes control plane is reachable.
- The CoreDNS service is discoverable.

Do not hardcode or record the generated cluster endpoint.

## 2. Validate Nodes

```bash
kubectl get nodes -o wide
```

Expected:

- Exactly `2` nodes for the current lab configuration.
- Both nodes have `STATUS` set to `Ready`.
- Node versions are compatible with Kubernetes `1.36`.
- No node has an `EXTERNAL-IP`.

`Ready` alone is insufficient. A node can be Ready while still having placement,
networking, DNS, add-on, or drift issues that would affect workloads later.

## 3. Validate Node Placement And Private Networking

```bash
kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,INTERNAL-IP:.status.addresses[?(@.type=="InternalIP")].address,EXTERNAL-IP:.status.addresses[?(@.type=="ExternalIP")].address,PROVIDER-ID:.spec.providerID'
```

Expected:

- Nodes have private `10.10.x.x` internal addresses.
- `EXTERNAL-IP` is empty or shown as `<none>`.
- Provider IDs show placement across `us-east-1a` and `us-east-1b`.

This validates the intended private-worker and multi-AZ placement design. It
does not, by itself, prove that all outbound egress behavior is healthy.

## 4. Validate System Workloads

```bash
kubectl get pods -A -o wide
```

Expected `kube-system` baseline:

- `aws-node`: `Running` and Ready on every node.
- `kube-proxy`: `Running` and Ready on every node.
- `eks-pod-identity-agent`: `Running` and Ready on every node.
- `coredns`: `2` `Running` and Ready replicas.

Component meaning:

- `aws-node` validates VPC CNI and network integration.
- `kube-proxy` validates Kubernetes service networking.
- `coredns` validates cluster DNS.
- `eks-pod-identity-agent` validates the EKS Pod Identity node agent.

Unexpected restarts should be investigated even when a pod is currently
`Running`.

## 5. Validate Terraform Convergence

From `environments/lab-eks`:

```bash
terraform plan -lock=false -no-color
```

Expected:

```text
No changes. Your infrastructure matches the configuration.
```

AWS and Kubernetes appearing healthy is not enough if Terraform still detects
drift. Terraform convergence confirms that the declared infrastructure state and
observed remote state still match.

If IAM bootstrap changes were made, validate `bootstrap/identity` separately.

## 6. Definition Of Done

- [ ] Kubernetes API reachable
- [ ] 2/2 nodes Ready
- [ ] Nodes distributed across `us-east-1a` and `us-east-1b`
- [ ] No worker node has `ExternalIP`
- [ ] `aws-node` healthy on both nodes
- [ ] `kube-proxy` healthy on both nodes
- [ ] `eks-pod-identity-agent` healthy on both nodes
- [ ] 2 CoreDNS replicas healthy
- [ ] No unexplained system pod restarts
- [ ] `environments/lab-eks` Terraform plan converged
- [ ] `bootstrap/identity` Terraform plan converged when applicable

## 7. Failure Triage

| Symptom | First Investigation Areas |
| --- | --- |
| Node `NotReady` | Node conditions, kubelet, CNI, IAM, network reachability |
| `aws-node` unhealthy | VPC CNI, Pod Identity association, IAM, subnet/IP capacity |
| CoreDNS unhealthy | Scheduling, CNI, DNS/service networking, resource pressure |
| Node group `CREATE_FAILED` | `aws eks describe-nodegroup`, EC2/ASG launch failures, instance type capacity, account restrictions, node IAM, networking |
| Terraform plan fails during refresh | Inspect the exact denied read action; do not blindly broaden IAM permissions |
| Terraform drift | Determine whether AWS was changed manually or desired state changed; do not blindly apply before understanding the diff |

## 8. Current Known-Good Baseline

Validation date: `2026-09-02`

Stable non-sensitive observations:

- 2 nodes Ready.
- Worker nodes use private IPs only.
- Nodes are distributed across `us-east-1a` and `us-east-1b`.
- Expected `kube-system` components are `Running`.
- Zero unexplained restarts were observed during validation.
- Terraform converged with no changes.

Do not include:

- Generated EKS API endpoint.
- EC2 instance IDs.
- Temporary credentials.
- MFA values.
- AWS session tokens.

This baseline should be captured before introducing application workloads,
observability components, autoscaling, or reliability experiments.
