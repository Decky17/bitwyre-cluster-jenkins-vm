# -----------------------------------------------------------------------------
# VARIABLE
# -----------------------------------------------------------------------------
variable project_id {
  type        = map(string)
  description = "The project ID to host the resources in"
  default = {
    prd = "bitwyre-production"
  }
}