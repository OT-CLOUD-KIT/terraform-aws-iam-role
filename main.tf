locals {
  policies = { for i, v in var.policies : var.policies[i]["name"] => v }
  
  rolep = flatten([
    for role in var.roles : [
      for policy in role["policies"] : {
        role_name   = role.name
        policy_name = policy
        policy      = local.policies[policy]
      }
    ]
  ])

  role_policies = { for obj in local.rolep : "${obj.role_name}:${obj.policy_name}" => obj.policy }

  inlinepol = flatten([
    for role in var.roles : [
      for inline_policy in role["inline_policies"] : {
        role_name   = role.name
        policy_name = inline_policy["name"]
        policy      = merge(inline_policy, { role_name = role.name })
      }
    ]
  ])

  inline_policies = { for i, obj in local.inlinepol : i => obj.policy }


  policyar = flatten([
    for role in var.roles : [
      for policy_arn in role["policy_arns"] : {
        role_name  = role.name
        policy_arn = policy_arn
        policy     = policy_arn
      }
    ]
  ])

  policy_arns = { for obj in local.policyar : "${obj.role_name}:${obj.policy_arn}" => obj.policy }

}

# -------------------------------------------------------------------------------------------------
# Create defined Policies
# -------------------------------------------------------------------------------------------------

module "name_iam_policy" {
  for_each = local.policies
  # source   = "naming-tag"
  source   = "git@github.com:OT-CLOUD-KIT/terraform-aws-naming.git?ref=dev"

  bu       = var.bu
  env      = var.env
  app      = var.app 
  tenant   = var.tenant
  resource = "${each.value.name}-policy"
}
 
# Create customer managed policies
resource "aws_iam_policy" "policies" {
  for_each = local.policies
  tags = merge(
    {
      "Name" : module.name_iam_policy[each.key].naming_tag[0] 
    },
    var.policies_tags,
  )


  name        = module.name_iam_policy[each.key].naming_tag[0] 
  path        = lookup(each.value, "path", null) == null ? var.policy_path : lookup(each.value, "path")
  description = lookup(each.value, "desc", null) == null ? var.policy_desc : lookup(each.value, "desc")
  policy      = var.use_root_path_template ? lookup(each.value, "policy_template_file") == null ? jsonencode(jsondecode(lookup(each.value, "policy_statement"))) : templatefile(lookup(each.value, "policy_template_file"), lookup(each.value, "policy_template_vars")) : lookup(each.value, "policy_template_file") == null ? jsonencode(jsondecode(lookup(each.value, "policy_statement"))) : templatefile("${path.module}/policy-documents/${lookup(each.value, "policy_template_file")}", lookup(each.value, "policy_template_vars"))
}

# -------------------------------------------------------------------------------------------------
# Create Roles
# -------------------------------------------------------------------------------------------------

# Create roles
module "name_iam_role" {
  for_each = { for i, role in var.roles : role["name"] => role }
  # source   = "naming-tag"
  source   = "git@github.com:OT-CLOUD-KIT/terraform-aws-naming.git?ref=dev"

  bu       = var.bu
  env      = var.env
  app      = var.app
  tenant   = var.tenant
  resource = "${each.value.name}-role"
}

resource "aws_iam_role" "roles" {
  for_each = { for i,role in var.roles : role["name"] => role }

  name        = module.name_iam_role[each.key].naming_tag[0] 
  path        = lookup(each.value, "path", null) == null ? var.role_path : lookup(each.value, "path")
  description = lookup(each.value, "desc", null) == null ? var.role_desc : lookup(each.value, "desc")

  # This policy defines who/what is allowed to use the current role
  assume_role_policy = var.use_root_path_template ? templatefile(lookup(each.value.trust_policy, "policy_template_file"), lookup(each.value.trust_policy, "policy_template_vars")) : templatefile("${path.module}/policy-documents/${lookup(each.value.trust_policy, "policy_template_file")}", lookup(each.value.trust_policy, "policy_template_vars"))

  # The boundary defines the maximum allowed permissions which cannot exceed.
  # Even if the policy has higher permission, the boundary sets the final limit
  permissions_boundary = lookup(var.permissions_boundaries, each.key, "")

  # Allow session for X seconds
  max_session_duration  = var.max_session_duration
  force_detach_policies = var.force_detach_policies

  tags = merge(
    {
      "Name" : module.name_iam_role[each.key].naming_tag[0] 
    },
    var.roles_tags,
  )

}


# -------------------------------------------------------------------------------------------------
# Attach Policies to Role
# -------------------------------------------------------------------------------------------------

# Attach customer managed policies
resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each = local.role_policies

  role       =  module.name_iam_role[replace(each.key, format(":%s", each.value.name), "")].naming_tag[0] 
  policy_arn = aws_iam_policy.policies[each.value.name].arn

  # Terraform has no info that aws_iam_roles and aws_iam_policies
  # must be run first in order to create the roles,
  # so we must explicitly tell it.
  depends_on = [
    aws_iam_role.roles,
    aws_iam_policy.policies,
  ]
}

# Attach policy ARNs
resource "aws_iam_role_policy_attachment" "policy_arn_attachments" {
  for_each = local.policy_arns

  role       = module.name_iam_role[replace(each.key, format(":%s", each.value), "")].naming_tag[0] 
  policy_arn = each.value

  # Terraform has no info that aws_iam_roles must be run first in order to create the roles,
  # so we must explicitly tell it.
  depends_on = [aws_iam_role.roles]
}

# Attach inline policies
module "name_iam_role_policy" {
  for_each = local.inline_policies
  # source   = "naming-tag"
  source   = "git@github.com:OT-CLOUD-KIT/terraform-aws-naming.git?ref=dev"

  bu       = var.bu
  env      = var.env
  app      = var.app
  tenant   = var.tenant
  resource = "${each.value.name}-policy"
}

resource "aws_iam_role_policy" "inline_policy_attachments" {
  for_each = local.inline_policies
 
  name   = module.name_iam_role_policy[each.key].naming_tag[0] 
  role   = module.name_iam_role[each.value.role_name].naming_tag[0]
  policy = lookup(each.value, "policy_template_file") == null ? jsonencode(jsondecode(lookup(each.value, "policy_statement"))) :  templatefile(lookup(each.value, "policy_template_file"), lookup(each.value, "policy_template_vars"))

  # Terraform has no info that aws_iam_roles must be run first in order to create the roles,
  # so we must explicitly tell it.
  depends_on = [aws_iam_role.roles]
}
