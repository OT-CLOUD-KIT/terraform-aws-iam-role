
# -------------------------------------------------------------------------------------------------
# Create defined Policies
# -------------------------------------------------------------------------------------------------

# module "name_iam_policy" {
#   for_each = var.create_iam_policies ? local.policies : {}

#   # source   = "naming-tag"
#   source   = "git@github.com:OT-CLOUD-KIT/terraform-aws-naming.git?ref=dev"

#   bu       = var.bu
#   env      = var.env
#   app      = var.app 
#   tenant   = var.tenant
#   resource = "${each.value.name}-policy"
# }
 
# Create customer managed policies
resource "aws_iam_policy" "policies" {
  for_each = var.create_iam_policies ? local.policies : {}

  tags = merge(
    {
      "Name" = local.iam_policy_names[each.key]
    },
    local.policies_tags,
  )


  name        = local.iam_policy_names[each.key]
  path        = lookup(each.value, "path", null) == null ? var.policy_path : lookup(each.value, "path")
  description = lookup(each.value, "desc", null) == null ? var.policy_desc : lookup(each.value, "desc")
  policy      = var.use_root_path_template ? lookup(each.value, "policy_template_file") == null ? jsonencode(jsondecode(lookup(each.value, "policy_statement"))) : templatefile(lookup(each.value, "policy_template_file"), lookup(each.value, "policy_template_vars")) : lookup(each.value, "policy_template_file") == null ? jsonencode(jsondecode(lookup(each.value, "policy_statement"))) : templatefile("${path.module}/policy-documents/${lookup(each.value, "policy_template_file")}", lookup(each.value, "policy_template_vars"))
}

# -------------------------------------------------------------------------------------------------
# Create Roles
# -------------------------------------------------------------------------------------------------

# module "name_iam_role" {

#   for_each = var.create_iam_roles ? { for role in var.roles : role["name"] => role } : {}
#   source   = "git@github.com:OT-CLOUD-KIT/terraform-aws-naming.git?ref=dev"

#   bu       = var.bu
#   env      = var.env
#   app      = var.app
#   tenant   = var.tenant
#   resource = "${each.value.name}-role"
# }

resource "aws_iam_role" "roles" {

  for_each = var.create_iam_roles ? { for role in var.roles : role["name"] => role } : {}

  name        = local.iam_role_names[each.key]
  path        = lookup(each.value, "path", null) == null ? var.role_path : lookup(each.value, "path")
  description = lookup(each.value, "desc", null) == null ? var.role_desc : lookup(each.value, "desc")

  assume_role_policy = var.use_root_path_template ? templatefile(lookup(each.value.trust_policy, "policy_template_file"), lookup(each.value.trust_policy, "policy_template_vars")) : templatefile("${path.module}/policy-documents/${lookup(each.value.trust_policy, "policy_template_file")}", lookup(each.value.trust_policy, "policy_template_vars"))

  permissions_boundary = lookup(var.permissions_boundaries, each.key, "")

  max_session_duration  = var.max_session_duration
  force_detach_policies = var.force_detach_policies

  tags = merge(
    {
      "Name" = local.iam_role_names[each.key]
    },
    local.roles_tags,
  )

}


# -------------------------------------------------------------------------------------------------
# Attach Policies to Role
# -------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each = var.create_iam_roles && var.create_iam_policies ? local.role_policies : {}


  role       = local.iam_role_names[replace(each.key, format(":%s", each.value.name), "")]
  policy_arn = aws_iam_policy.policies[each.value.name].arn


  depends_on = [
    aws_iam_role.roles,
    aws_iam_policy.policies,
  ]
}

resource "aws_iam_role_policy_attachment" "policy_arn_attachments" {

  for_each = var.attach_policy_arns ? local.policy_arns : {}

  role       = local.iam_role_names[replace(each.key, format(":%s", each.value), "")]
  policy_arn = each.value
  depends_on = [aws_iam_role.roles]
}

# module "name_iam_role_policy" {
#   for_each = var.create_iam_policies ? local.policies : {}
#   source   = "git@github.com:OT-CLOUD-KIT/terraform-aws-naming.git?ref=dev"

#   bu       = var.bu
#   env      = var.env
#   app      = var.app
#   tenant   = var.tenant
#   resource = "${each.value.name}-policy"
# }

resource "aws_iam_role_policy" "inline_policy_attachments" {


  for_each = var.attach_inline_policies ? local.inline_policies : {}
 
  name   = local.iam_inline_policy_names[each.key]
  role   = local.iam_role_names[each.value.role_name]
  policy = lookup(each.value, "policy_template_file") == null ? jsonencode(jsondecode(lookup(each.value, "policy_statement"))) :  templatefile(lookup(each.value, "policy_template_file"), lookup(each.value, "policy_template_vars"))
  depends_on = [aws_iam_role.roles]
}
