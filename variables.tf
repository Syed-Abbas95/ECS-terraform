variable "REGION" {
  type    = string
  default = "eu-west-3"
}

variable "NAME" {
  type    = string
  default = "testing"
}

variable "AMI" {
  type = map(string)
  default = {
    "ubuntu" = "ami-03ceeb33c1e4abcd1"
    "linux"  = "ami-03c6b308140d10488"
  }
}

variable "INSTANCE_TYPE" {
  type    = string
  default = "t3.micro"
}

variable "KEY_PAIR_NAME" {
  type    = string
  default = "Abbaskey"
}