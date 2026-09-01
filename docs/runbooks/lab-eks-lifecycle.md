# Lab EKS Lifecycle Runbook

This runbook documents the intended manual lifecycle for the ephemeral lab EKS
stack. It is documentation only; do not run these commands as part of review.

## Terraform States

- `environments/lab` owns the persistent network foundation: VPC, subnets,
  route tables, Internet Gateway and optional EKS egress through NAT.
- `environments/lab-eks` owns the ephemeral EKS layer: IAM roles, EKS cluster,
  managed add-ons, access entries and managed node group.

The EKS root reads the network root through Terraform remote state:

- Bucket: `infra-iac-978121310268-tfstate`
- Key: `environments/lab/terraform.tfstate`

Future CI roles for `environments/lab-eks` need read-only access to this exact
network state object in addition to their own EKS state permissions.

## Create Order

Enable EKS egress in the network root first. The current lab design uses a
single NAT Gateway as a cost and availability trade-off.

```bash
cd environments/lab
terraform init -backend-config="bucket=infra-iac-978121310268-tfstate"
terraform plan -out=egress-on.tfplan
terraform apply egress-on.tfplan
```

Then create the EKS root.

```bash
cd environments/lab-eks
terraform init -backend-config="bucket=infra-iac-978121310268-tfstate"
terraform plan -out=create.tfplan
terraform apply create.tfplan
```

## Human Access

The `eks-lab-admin` IAM role is the stable Kubernetes admin principal. It is
granted cluster-scoped admin access through EKS Access Entries, not `aws-auth`.
Its trust policy requires MFA from the configured stable IAM user or role.

After creation, assume the role with MFA and build kubeconfig:

```bash
aws sts assume-role \
  --role-arn "$(terraform output -raw eks_admin_role_arn)" \
  --role-session-name lab-eks-admin \
  --serial-number "<mfa-device-arn>" \
  --token-code "<mfa-code>"

aws eks update-kubeconfig \
  --region us-east-1 \
  --name "$(terraform output -raw cluster_name)" \
  --role-arn "$(terraform output -raw eks_admin_role_arn)"

kubectl get nodes
kubectl get pods -A
```

Do not use STS session ARNs in EKS Access Entries. Access entries should point
to stable IAM user or role ARNs.

## Destroy Order

Destroy the EKS root before disabling EKS egress or tearing down the network.
Nodes need private subnet egress while the node group and add-ons are being
deleted.

```bash
cd environments/lab-eks
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Verify the EKS root is empty before disabling egress:

```bash
terraform plan -no-color
```

Then disable optional EKS egress in the persistent network root:

```bash
cd environments/lab
terraform plan -var='enable_eks_egress=false' -out=egress-off.tfplan
terraform apply egress-off.tfplan
```

Disabling `enable_eks_egress` should remove only:

- the NAT Elastic IP
- the NAT Gateway
- the private subnet default IPv4 routes to NAT

It should preserve the VPC, subnets, route tables and Internet Gateway.

## Notes

- No `terraform -target` is part of the normal lifecycle.
- No Karpenter, Fargate, load balancer controller, Argo CD, observability stack,
  application workloads, ingress or VPC endpoints are included in this phase.
- Managed add-on versions are intentionally not pinned in Terraform. EKS selects
  a compatible default for Kubernetes 1.36 during creation. Pinning can be added
  later after checking available versions for the exact cluster version.
