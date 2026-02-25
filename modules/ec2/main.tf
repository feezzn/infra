data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_iam_role" "ssm" {
  name = "${var.name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = "${var.name}-ssm-role" })
}
# aqui é criada uma função do IAM para o AWS Systems Manager (SSM), permitindo que  a instância EC2 assuma essa função para usar os recursos do SSM. A política de confiança especifica que a função pode ser assumida por serviços EC2.
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# aqui é criado um perfil de instância do IAM que associa a função SSM criada anteriormente. Isso permite que a instância EC2 use o AWS Systems Manager para gerenciamento e automação. 
resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.ssm.name
  tags = merge(var.tags, { Name = "${var.name}-instance-profile" })
}
# aqui fica a definição da instância EC2, utilizando a AMI do Amazon Linux 2023, o tipo de instância, a sub-rede e o grupo de segurança fornecidos como variáveis. A instância também é associada ao perfil de instância criado anteriormente para permitir o uso do SSM.
resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile = aws_iam_instance_profile.this.name

  user_data = <<-EOF
  #!/bin/bash
  set -euxo pipefail

  yum install -y amazon-ssm-agent || true
  systemctl enable --now amazon-ssm-agent
EOF

  user_data_replace_on_change = true
  metadata_options {
    http_tokens = "required"
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}