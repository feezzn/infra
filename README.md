```md
![Terraform CI](https://github.com/feezzn/infra/actions/workflows/terraform.yml/badge.svg)

# ☁️ AWS Infrastructure — Terraform + EKS + GitHub OIDC

Infrastructure as Code (IaC) project to provision and operate AWS infrastructure using **Terraform**, following **enterprise-grade practices** for security, automation, and reproducibility.

---

## 1. Overview

This repository provisions a complete AWS infrastructure from scratch, including networking, Kubernetes (EKS), remote Terraform state management, and CI/CD automation via GitHub Actions using **OIDC (no long-lived credentials)**.

---

## 2. Objectives

- Fully reproducible infrastructure using Terraform
- Clear separation of environments (dev / prod / global)
- Secure CI/CD authentication using GitHub OIDC
- Remote Terraform state with locking and encryption
- Kubernetes-ready foundation for GitOps (Argo CD)

---

## 3. Architecture

### 3.1 C4 — System Context

```mermaid
flowchart LR
  Developer -->|git push| GitHub
  GitHub -->|OIDC| AWS
  AWS --> EKS
  AWS --> S3
  AWS --> DynamoDB

---

## 4. Repository Structure
environments/
  dev/        # automatic apply via CI
  prod/       # apply with manual approval
  global/     # shared/global resources (budget, etc)
modules/
  vpc/        # custom VPC module
  eks/        # EKS module (terraform-aws-modules)
bootstrap/
  backend/    # remote backend (S3 + DynamoDB)

---

5. Terraform State & Backend
S3 stores the Terraform state file
DynamoDB provides state locking
Backend resources are created via bootstrap/backend
State is encrypted and versioned

---

6. CI/CD — GitHub Actions
Authentication
GitHub Actions authenticates to AWS using OIDC
No access keys stored in GitHub or locally
Temporary credentials via AWS STS
Workflow Behavior
terraform fmt / validate / plan on push
dev: automatic plan + apply on main
prod / global: apply requires manual approval via GitHub Environments

---

7. Security Considerations
No long-lived AWS credentials
IAM roles scoped with least privilege
Remote state protected by locking
Kubernetes access managed via IAM + EKS access entries
Ready for IRSA and GitOps security patterns

---

8. How to Operate Locally
Prerequisites
Terraform
AWS CLI
kubectl

---

9. Current State
EKS cluster: ACTIVE
Kubernetes version: 1.34
Node groups: 1 (AL2023)
Core addons: healthy
Terraform: converged (no drift)

---

10. Next Steps
Install Argo CD (GitOps)
Deploy sample application via GitOps
Harden EKS networking and endpoint access
Introduce autoscaling strategy
Prepare upgrade path for Kubernetes versions

---

Felipe
Site Reliability / DevOps Engineer
Focused on secure, reproducible cloud infrastructure