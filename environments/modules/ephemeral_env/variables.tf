variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "ephemeral_env" {
  type = string
}

variable "alb" {
  type = object({
    instance     = any
    listener_arn = string
  })
}

variable "ecs_cluster_id" {
  type = string
}

variable "dns" {
  type = object({
    zone_id      = string,
    record_name  = string,
    record_value = string
  })
}
