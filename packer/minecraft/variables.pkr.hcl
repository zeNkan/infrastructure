variable "users" {
  type = list(object({
    name        = string
    password    = string
    ssh_pub_key = string
  }))
}


variable "esxi_host" {
  type    = string
}

variable "esxi_password" {
  type    = string
}

variable "esxi_portgroup" {
  type    = string
}

variable "esxi_username" {
  type    = string
}

variable "minecraft_rcon" {
  type    = string
}

variable "minecraft_rcon_port" {
  type    = string
}

variable "webhook_id" {
  type    = string
}

variable "webhook_secret" {
  type    = string
}
