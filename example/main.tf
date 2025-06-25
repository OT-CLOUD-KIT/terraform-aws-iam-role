data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "standard_tags" {
  source  = "git@github.com:OT-CLOUD-KIT/terraform-aws-standard-tagging.git?ref=dev"
  env     = var.env
  app     = var.app
  bu      = var.bu
  program = "edcil"
  team    = "lspl"
  region  = "us-east-1"
}

module "assume_role" {
  source = "../"

  env = var.env
  app = var.app
  bu  = var.bu

  policies_tags = module.standard_tags.standard_tags
  roles_tags    = module.standard_tags.standard_tags

  create_iam_roles       = var.create_iam_roles
  create_iam_policies    = var.create_iam_policies
  attach_policy_arns     = var.attach_policy_arns
  attach_inline_policies = var.attach_inline_policies

  roles = [
    for role in var.roles : {
      name = role.name
      path = role.path
      desc = role.desc
      trust_policy = {
        policy_template_file = role.trust_policy.policy_template_file
        policy_template_vars = merge(
          try(role.trust_policy.policy_template_vars, {}),
          {
            # "eks_oidc_arn"   = module.composite_eks.eks_oidc["arn"]
            # "eks_oidc_url"   = local.oidc_url[1]
          }
        )
      }
      policies    = role.policies
      policy_arns = role.policy_arns
    }
  ]

  policies = [
    for policy in var.policies : {
      name                 = policy.name
      path                 = policy.path
      desc                 = policy.desc
      policy_template_file = policy.policy_template_file
      policy_template_vars = merge(
        try(policy.policy_template_vars, {}),
        {
          "account_id" = data.aws_caller_identity.current.account_id
          "region"     = data.aws_region.current.id
        }
      )
    }
  ]

}