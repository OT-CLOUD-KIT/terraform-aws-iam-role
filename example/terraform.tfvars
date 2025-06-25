env    = "d"
bu     = "ot"
app    = "bp"
tenant = ""

max_session_duration   = 3600
create_iam_roles       = true
create_iam_policies    = true
attach_policy_arns     = true
attach_inline_policies = true

policies = [
  {
    name                 = "ec2-access"
    path                 = null
    desc                 = "Grants full access to EC2 resources"
    policy_template_file = "../../policy-documents/ec2-full-access-policy.tpl"
  }
]

roles = [
  {
    name = "ec2-access"
    path = "/"
    desc = "Allow BuildPiper to access EC2 resources"
    trust_policy = {
      policy_template_file = "../../policy-documents/assume-role-trust.tpl"
      policy_template_vars = {
        "account_id"       = "340752832494"
        "assume_role_name" = "BP_adminIAMrole"
      }
    }
    policies    = ["ec2-access"]
    policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }
]