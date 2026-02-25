variable "name" {}
variable "vpc_id" {}
variable "ingress_rules" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = string
  }))
}
variable "tags" {
  type    = map(string)
  default = {}
}