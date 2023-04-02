variable "dashboard-version" {
  type    = string
  description = "This is the kubernetes dashboard version, default value is compatible with the kubernetes version v1.25"
  default = "v2.7.0"
}

variable "dms-version" {
  type    = string
  description = "This is the kubernetes dashboard metrics scraper version,default value is compatible with the kubernetes version v1.25"
  default = "v1.0.8"
}

