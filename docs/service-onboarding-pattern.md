# Service Onboarding Pattern (ECS, Airflow, DB)

## Objetivo

Padronizar como novos serviços entram no repositório sem quebrar governança de rede, segurança e CI/CD.

## Regras de padrão

1. Todo serviço novo entra por ambiente (`environments/dev|prod|global`).
2. Todo serviço usa VPC existente (subnets privadas por padrão).
3. Todo serviço recebe tags padrão via `provider.default_tags`.
4. Toda mudança passa por `plan` e somente depois `apply`.
5. Segredos ficam fora do código (SSM/Secrets Manager).

## Layout recomendado

```
modules/
  ecs-service/
  mwaa/
  documentdb/

environments/<env>/
  services-ecs.tf
  services-airflow.tf
  services-db.tf
  terraform.tfvars
```

## Padrão de inputs por serviço

### ECS

- `name`
- `cpu`
- `memory`
- `desired_count`
- `container_image`
- `container_port`
- `subnet_ids` (privadas)
- `security_group_ids`

### Airflow (MWAA)

- `name`
- `airflow_version`
- `environment_class`
- `max_workers`
- `min_workers`
- `dag_s3_path`
- `requirements_s3_path`
- `subnet_ids` (privadas)
- `security_group_ids`

### Database (geral)

- `engine` (`postgres`, `mysql`, `docdb`)
- `instance_class`
- `allocated_storage` (RDS)
- `db_name`
- `username_secret_arn`
- `password_secret_arn`
- `subnet_ids` (privadas)
- `security_group_ids`

## Estratégia para Mongo

Para padrão corporativo AWS, usar **DocumentDB** como opção gerenciada compatível em vários cenários de MongoDB.

Se a necessidade for Mongo nativo (Atlas), manter módulo dedicado externo e tratar peering/PrivateLink como integração de rede.

## Fluxo operacional

1. Criar arquivo de serviço no ambiente (ex.: `services-ecs.tf`).
2. Referenciar módulo versionado em `modules/<servico>`.
3. Executar `Infra CI` (fmt, validate, tflint, tfsec).
4. Rodar `Infra CD` com `action=plan`.
5. Aprovar e rodar `action=apply`.