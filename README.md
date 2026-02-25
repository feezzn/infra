![Terraform CI](https://github.com/feezzn/infra/actions/workflows/terraform.yml/badge.svg)

# ☁️ Infrastructure as Code - AWS + Terraform + GitHub OIDC

Projeto de infraestrutura como código (IaC) utilizando boas práticas modernas de segurança, automação e CI/CD.

## 🏗️ Stack Utilizada
- Terraform
- AWS
- GitHub Actions
- OIDC (OpenID Connect)
- IAM Roles
- STS (Security Token Service)

---

## 📁 Estrutura do Repositório

```text
environments/
  dev/     # apply automático via CI
  prod/    # apply com aprovação (GitHub Environments)
  global/  # recursos globais (ex: budget) com aprovação
modules/
  vpc/     # módulo reutilizável de VPC (public/private subnets)
bootstrap/
  backend/ # criação do backend remoto (S3 + DynamoDB)
```
---

🔐 Autenticação Segura (Sem Access Keys)

- Este projeto utiliza OIDC para permitir que o GitHub Actions assuma uma IAM Role diretamente na AWS.
- Não há credenciais estáticas armazenadas no repositório.
- Fluxo: GitHub Actions → Gera token OIDC temporário → AWS STS valida token → Assume IAM Role → Permissões temporárias são concedidas

---

🧱 Backend Remoto (State + Lock)

- O state do Terraform é armazenado em S3 e protegido por lock no DynamoDB.
- S3: armazenamento do terraform.tfstate
- DynamoDB: lock para evitar concorrência durante apply

---

## ⚙️ CI Pipeline

Workflow executado a cada push na branch `main`:

1. Checkout do código
2. Autenticação via OIDC
3. Validação de identidade (`aws sts get-caller-identity`)
4. (Em evolução) Terraform init / validate / plan
5. dev: plan + apply automático em push na main
6. prod/global: apply somente após aprovação (GitHub Environments)

---

## 🎯 Objetivo do Projeto

Construir uma base sólida para:

- Separação de ambientes (dev / prod)
- Backend remoto com S3 + DynamoDB
- Controle de aprovação para produção
- Estrutura modular Terraform
- Práticas de FinOps (budget e alertas)

---

💰 FinOps (Budget)

- Budget global para controle de gasto mensal
- Notificações por e-mail ao atingir percentual do limite

---

🧠 Próxima Evolução

- Security Groups + EC2 (acesso via SSM, sem SSH)
- Base para EKS/ECS
- Self-service provisioning (futuro)
- Evolução multi-cloud (Azure) no futuro

---

## 👨‍💻 Autor

Felipe 😄
Estudando DevOps e construindo prática real com foco em segurança e automação.