variable "resource_group_name" {
  description = "Name of the RG passed from root"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "prefix" {
  description = "Prefix for naming (e.g., india or us)"
  type        = string
}