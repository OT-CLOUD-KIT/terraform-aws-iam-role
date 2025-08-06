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
    desc                 = "Allows full access to all EC2 resources and actions."
    policy_template_file = "policy-documents/ec2-full-access-policy.tpl"
  },

  {
    name                 = "s3-access"
    path                 = null
    desc                 = "Allows full access to all S3 buckets and related actions."
    policy_template_file = "policy-documents/s3-policy.tpl"
  }
]

roles = [
  {
    name = "ec2-access"
    path = "/"
    desc = "IAM role that can be assumed by IAM user 'Mohit' to manage EC2 and S3 resources."
    trust_policy = {
      policy_template_file = "policy-documents/assume-role-trust.tpl"
      policy_template_vars = {
        assume_type = "user"           # or "role"
        assume_name = "Mohit"
        account_id  = "509633460021"
      }
    }
    policies    = ["ec2-access", "s3-access"]
    policy_arns = [ "arn:aws:iam::aws:policy/ReadOnlyAccess" ]
  },

  {
    name = "s3-access"
    path = "/"
    desc = "IAM role that can be assumed by role 'demo-a' to access S3 resources with limited (read-only) permissions."
    trust_policy = {
      policy_template_file = "policy-documents/assume-role-trust.tpl"
      policy_template_vars = {
        assume_type = "role"
        assume_name = "demo-a"
        account_id  = "509633460021"
      }
    }
    policies    = ["s3-access"]
    policy_arns = [ "arn:aws:iam::aws:policy/ReadOnlyAccess" ]
  }
]
