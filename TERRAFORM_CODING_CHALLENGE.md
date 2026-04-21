# Terraform Live Coding - HackerRank Style

## 🎯 Como funciona

Em plataformas tipo HackerRank/LeetCode com Terraform:

1. **Recebe um "problema"** (em português/inglês)
2. **Escreve Terraform code**
3. **Validação automática:**
   - `terraform validate` (syntax ok?)
   - `terraform plan` (resources criados?)
   - Testa outputs e variáveis

**Não é deploy para Azure de verdade!** É só validação local.

---

## 🔧 ANTES DE COMEÇAR

### Setup necessário:

```bash
# 1. Certifique-se que terraform está instalado
terraform version

# 2. Você pode usar um backend fake (local)
# O HackerRank faz o scoring automaticamente
```

### Provider simples:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true  # ← Importante! Não usa Azure de verdade
}
```

---

## 💡 TIPOS DE PROBLEMAS

### TIPO 1: "Crie um recurso simples"

**Problema:**
```
Create an Azure Storage Account with the following requirements:
- Name: "mystorageaccount"
- Resource Group: "myresourcegroup"
- Location: "eastus"
- Account Tier: "Standard"
- Replication: "LRS"
```

**Solução:**

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "myresourcegroup"
  location = "eastus"
}

resource "azurerm_storage_account" "storage" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "storage_account_id" {
  value = azurerm_storage_account.storage.id
}
```

**Estratégia:**
1. Lê o problema
2. Identifica os recursos (RG + Storage)
3. Escreve resource blocks
4. Adiciona outputs (eles checam!)
5. `terraform validate` pra confirmar

---

### TIPO 2: "Crie múltiplos recursos relacionados"

**Problema:**
```
Create:
1. VNet with CIDR 10.0.0.0/16
2. Subnet with CIDR 10.0.1.0/24
3. NSG with a rule allowing SSH (port 22)
4. Associate NSG to the subnet

All in resource group "test-rg" in "westus"
```

**Solução:**

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "test-rg"
  location = "westus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
```

**Estratégia:**
1. Desenha no papel a arquitetura (RG → VNet → Subnet → NSG)
2. Escreve em ordem (top-down)
3. Usa referências (não hardcode!)
4. Adiciona outputs
5. `terraform validate`

---

### TIPO 3: "Use variáveis"

**Problema:**
```
Create resources using variables:
- variable "location" = "eastus"
- variable "env_name" = "prod"
- variable "vm_count" = 2

Create:
- Resource group: "rg-<env_name>"
- Name VMs: "vm-<env_name>-1", "vm-<env_name>-2"
- Location: variable "location"
```

**Solução:**

```hcl
variable "location" {
  type    = string
  default = "eastus"
}

variable "env_name" {
  type    = string
  default = "prod"
}

variable "vm_count" {
  type    = number
  default = 2
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.env_name}"
  location = var.location
}

resource "azurerm_virtual_machine" "vms" {
  count               = var.vm_count
  name                = "vm-${var.env_name}-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # ... resto da config
}

output "vm_names" {
  value = azurerm_virtual_machine.vms[*].name
}
```

**Estratégia:**
1. Define variáveis no topo
2. Usa `${var.nome}` pra interpolar
3. Usa `count` pra criar múltiplos (se necessário)
4. Outputs com `[*]` pra arrays

---

### TIPO 4: "Use locals"

**Problema:**
```
Create a naming convention:
- Environment prefix: "prod"
- Team: "platform"
- Common name pattern: "${env}-${team}-resource"

Use locals to define this pattern.
Create 3 resources (storage, vnet, rg) following this pattern.
```

**Solução:**

```hcl
locals {
  env  = "prod"
  team = "platform"
  common_name = "${local.env}-${local.team}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.common_name}-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.common_name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_storage_account" "storage" {
  name                     = replace("${local.common_name}storage", "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

**Estratégia:**
1. `locals` pra valores reutilizáveis
2. Referencia com `local.nome`
3. Mantém DRY (Don't Repeat Yourself)

---

### TIPO 5: "AKS Cluster básico"

**Problema:**
```
Create an AKS cluster with:
- Cluster name: "aks-prod"
- 3 nodes
- VM size: Standard_D2s_v3
- Kubernetes version: 1.28
- In resource group "aks-rg"
- Location: eastus

Output the cluster ID and kubernetes version
```

**Solução:**

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "aks-rg"
  location = "eastus"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksprod"
  kubernetes_version  = "1.28"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "kubernetes_version" {
  value = azurerm_kubernetes_cluster.aks.kubernetes_version
}
```

**Estratégia:**
1. RG primeiro
2. AKS com referência ao RG
3. Default node pool com os requisitos
4. Identity (necessário)
5. Outputs!

---

## 🎯 ESTRATÉGIA GERAL PARA RESOLVER

### Passo 1: Lê o problema
- Identifica os recursos necessários
- Anota as dependências
- Entende o que precisa fazer output

### Passo 2: Desenha mentalmente
```
RG
├── VNet
│   └── Subnet
└── NSG
    └── Association
```

### Passo 3: Escreve em ordem
1. Provider
2. Variables (se houver)
3. Locals (se houver)
4. Recursos (em ordem de dependência)
5. Outputs

### Passo 4: Verifica
```bash
terraform validate
terraform fmt  # Formata bonito
```

### Passo 5: Testa
```bash
terraform plan  # Vê se tá ok
```

---

## ⚠️ ERROS COMUNS

### Erro 1: Esquecer referenceResource
```hcl
❌ ERRADO:
resource_group_name = "meu-rg"  # Hardcoded!

✅ CORRETO:
resource_group_name = azurerm_resource_group.rg.name
```

### Erro 2: Esquecer outputs
```hcl
❌ HackerRank não consegue validar sem outputs!

✅ SEMPRE adicione:
output "recurso_id" {
  value = azurerm_xxx.yyy.id
}
```

### Erro 3: Naming inválido
```hcl
❌ Nome com hífen em storage account:
name = "my-storage-account"  # Storage não permite hífen!

✅ Correto:
name = "mystorageaccount"
```

### Erro 4: Esquecer dependências
```hcl
❌ ERRADO:
resource "azurerm_subnet" "subnet" {
  # Sem referência ao VNet!
}

✅ CORRETO:
virtual_network_name = azurerm_virtual_network.vnet.name
resource_group_name  = azurerm_resource_group.rg.name
```

---

## 🧠 MINDSET

**Lembre-se:**

1. **Slow is smooth, smooth is fast**
   - Não saia digitando tudo rápido
   - Lê bem, planeja, escreve

2. **One resource at a time**
   - Escreve um recurso
   - `terraform validate`
   - Próximo

3. **Always reference**
   - Nunca hardcode IDs
   - Usa `azurerm_xxx.name.attribute`

4. **Test as you go**
   - `terraform validate` após cada recurso
   - Pega erros cedo

5. **Outputs are everything**
   - Eles teste VIA outputs
   - Sem outputs = sem validação

---

## 📝 QUICK REFERENCE

### Sintaxe Terraform:

```hcl
# Variable
variable "nome" {
  type    = string
  default = "valor"
}

# Local
locals {
  comum = "valor"
}

# Resource
resource "tipo_provider" "nome_local" {
  propriedade = valor
}

# Output
output "nome_output" {
  value = resource.nome_local.atributo
}

# Reference
outro_recurso = resource_tipo.nome.atributo

# Interpolation
name = "${local.prefixo}-${var.suffix}"
```

---

## 🎤 Se ficar preso na entrevista:

```
"Let me think about the dependencies here...
So I need X first, then Y can reference X..."

[Escreve um recurso]

"Let me validate this..."
terraform validate

"Now I can move to the next resource..."
```

**Mostra pensamento! Eles gostam disso.**

---

**VOCÊ TÁ PRONTO DEMAIS PRA ISSO!** 💪

Qualquer dúvida, me grita!
