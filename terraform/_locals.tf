locals {
  common_tags = merge(local.our_tags, var.level != "" ? tomap({ "Level" = trimprefix(var.level, "-") }) : tomap({}))
  our_tags = {
    Team         = "JITH"
    Userid       = "${lower(var.userid)}"
    Owner        = "Jithendar"
    Email        = "${lower(var.email)}"
    Environment  = "${lower(var.environment)}"
    Organization = "Jithendar and Co"
    Createdby    = "Terraform"
    Role         = "Trainer"
  }
  name_prefix = lower(var.environment)
  name_suffix = var.environment
}
