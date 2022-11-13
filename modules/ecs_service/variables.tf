variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "service_name" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "alb" {
  type = object({
    instance     = any
    listener_arn = string
  })
}

variable "host_name" {
  type = string
}

variable "service_docker_image" {
  type = string
}