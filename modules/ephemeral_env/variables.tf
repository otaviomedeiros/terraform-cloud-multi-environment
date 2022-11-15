variable "region" {
  description = "The AWS regions in which the resources will be provisioned"
  type        = string
}

variable "env_name" {
  description = "The name of the environment where the ephemeral one will be provisioned into. For example, stg or dev"
  type        = string
}

variable "ephemeral_env_name" {
  description = "The name of the ephemeral environment"
  type        = string
}

variable "alb" {
  description = "The load balancer which will forward requests to the ephemeral environment"

  type = object({
    instance     = any
    listener_arn = string
  })
}

variable "ecs_cluster_id" {
  description = "The ECS cluster where the ephemeral environment will deploy ECS services"
  type        = string
}

variable "dns" {
  description = "DNS info used to create the ephemeral environment DNS record"

  type = object({
    zone_id      = string,
    record_name  = string,
    record_value = string
  })
}
