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
