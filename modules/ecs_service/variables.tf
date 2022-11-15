variable "region" {
  description = "The AWS regions in which the resources will be provisioned"
  type        = string
}

variable "env_name" {
  description = "The name of the environment which will be appended to resource names"
  type        = string
}

variable "service_name" {
  description = "The name of the service. The ECS service name will have the env variable value as a sufix"
  type           = string
}

variable "ecs_cluster_id" {
  description = "The ECS cluster in which the ECS service will be placed into"
  type        = string
}

variable "alb" {
  description = "The load balancer which the ECS service will be attached to"

  type = object({
    instance     = any
    listener_arn = string
  })
}

variable "host_name" {
  description = "The service host name. The load balancer will forward requests to ECS service based on host name"
  type        = string
}

variable "service_docker_image" {
  description = "The ECS service docker image name"
  type        = string
}