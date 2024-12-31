env      = "d"
bu       = "ot"
app      = "bp"
tenant   = ""

permissions_boundaries = {}

policy_desc = "Managed by Terraform"

policy_path = "/"

role_desc = "Managed by Terraform"

role_path = "/"


max_session_duration = 3600

force_detach_policies = true

policies = [
  {
  name = "test-policy"
  path = null
  desc = "test-policy"
  policy_template_file = "./policy-documents/glue-policy.tpl"
  # policy_template_vars = {
  #   # "resource_list" = "\"arn:aws:kafka:<region>:<account-id>:topic/<cluster-name>/topic_a\",\"arn:aws:kafka:<region>:<account-id>:topic/<cluster-name>/topic_b\""
  # }
  },
  {
    name = "test-policy-2"
    path = null
    desc = "test-policy"
    policy_template_file = "./policy-documents/test.tpl"
    policy_template_vars = {
      "policy" = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"glue:CreateSchema\",\"glue:DeleteSchema\",\"glue:DescribeSchema\",\"glue:ListSchemas\",\"glue:CreateSchemaVersion\",\"glue:DeleteSchemaVersions\",\"glue:DescribeSchemaVersion\",\"glue:GetSchemaVersion\",\"glue:ListSchemaVersions\",\"glue:SearchSchemas\",\"glue:UpdateSchema\",\"glue:PutSchemaVersionMetadata\",\"glue:GetSchemaVersionMetadata\",\"glue:RemoveSchemaVersionMetadata\",\"glue:QuerySchemaVersionMetadata\"],\"Effect\":\"Allow\",\"Resource\":\"*\"}]}"
    }
  },
  {
    name = "test-policy-3"
    path = null
    desc = "test-policy"
    policy_statement =  "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"glue:CreateSchema\",\"glue:DeleteSchema\",\"glue:DescribeSchema\",\"glue:ListSchemas\",\"glue:CreateSchemaVersion\",\"glue:DeleteSchemaVersions\",\"glue:DescribeSchemaVersion\",\"glue:GetSchemaVersion\",\"glue:ListSchemaVersions\",\"glue:SearchSchemas\",\"glue:UpdateSchema\",\"glue:PutSchemaVersionMetadata\",\"glue:GetSchemaVersionMetadata\",\"glue:RemoveSchemaVersionMetadata\",\"glue:QuerySchemaVersionMetadata\"],\"Effect\":\"Allow\",\"Resource\":\"*\"}]}"
  }
]


roles = [
  {
    name = "test-1"
    path = "/"
    desc = "my test role for s3"
    trust_policy = {
      policy_template_file = "./policy-documents/assume-role-trust.tpl"
      policy_template_vars = {
        "account_id"       = "471112675494"
        "assume_role_name" = "root"
      }
    }
    policies        = ["test-policy-2"]
    policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },
  {
    name = "test-2"
    path = "/"
    desc = "my test role for ec2"
    trust_policy = {
      policy_template_file = "./policy-documents/service-role-trust.tpl"
      policy_template_vars = {
        "service_name" = "ec2.amazonaws.com"
      }
    }
    policies        = ["test-policy"]
    policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },
  {
    name = "test-3"
    path = "/"
    desc = "my test role for ec2"
    trust_policy = {
      policy_template_file = "./policy-documents/service-role-trust.tpl"
      policy_template_vars = {
        "service_name" = "ec2.amazonaws.com"
      }
    }
    inline_policies = [{
      name = "test-policy-5"
      policy_statement =  "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"glue:CreateSchema\",\"glue:DeleteSchema\",\"glue:DescribeSchema\",\"glue:ListSchemas\",\"glue:CreateSchemaVersion\",\"glue:DeleteSchemaVersions\",\"glue:DescribeSchemaVersion\",\"glue:GetSchemaVersion\",\"glue:ListSchemaVersions\",\"glue:SearchSchemas\",\"glue:UpdateSchema\",\"glue:PutSchemaVersionMetadata\",\"glue:GetSchemaVersionMetadata\",\"glue:RemoveSchemaVersionMetadata\",\"glue:QuerySchemaVersionMetadata\"],\"Effect\":\"Allow\",\"Resource\":\"*\"}]}"
    }]
    policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },
  {
    name = "test-4"
    path = "/"
    desc = "my test role for ec2"
    trust_policy = {
      policy_template_file = "./policy-documents/service-role-trust.tpl"
      policy_template_vars = {
        "service_name" = "ec2.amazonaws.com"
      }
    }
    inline_policies = [{
      name = "test-policy-4"
      policy_template_file = "./policy-documents/test.tpl"
      policy_template_vars = {
        "policy" = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":[\"glue:CreateSchema\",\"glue:DeleteSchema\",\"glue:DescribeSchema\",\"glue:ListSchemas\",\"glue:CreateSchemaVersion\",\"glue:DeleteSchemaVersions\",\"glue:DescribeSchemaVersion\",\"glue:GetSchemaVersion\",\"glue:ListSchemaVersions\",\"glue:SearchSchemas\",\"glue:UpdateSchema\",\"glue:PutSchemaVersionMetadata\",\"glue:GetSchemaVersionMetadata\",\"glue:RemoveSchemaVersionMetadata\",\"glue:QuerySchemaVersionMetadata\"],\"Effect\":\"Allow\",\"Resource\":\"*\"}]}"
      }
    }]
  },
  {
    name = "test-5"
    path = "/"
    desc = "my test role for ec2"
    trust_policy = {
      policy_template_file = "./policy-documents/service-role-trust.tpl"
      policy_template_vars = {
        "service_name" = "ec2.amazonaws.com"
      }
    }
  }
]