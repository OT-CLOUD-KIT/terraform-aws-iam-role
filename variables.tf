# -----------------------------------------------------------------------------------------
# Naming Convention Variables
# -----------------------------------------------------------------------------------------
variable "env" {
  description = "Environment name (e.g., dev, qa, prod)."
  type        = string
  default     = "Dev"
}



variable "app" {
  description = "Application name (e.g., bp, network, shared)."
  type        = string
  default     = "otcloudkit"
}


# -----------------------------------------------------------------------------------------
# IAM Policy Variables
# -----------------------------------------------------------------------------------------
variable "policies" {
  description = "List of IAM policies to create."
  type = list(object({
    name                 = string  # Policy name
    path                 = string  # Optional path, defaults to var.policy_path
    desc                 = string  # Optional description, defaults to var.policy_desc
    policy_template_file = optional(string, null)
    policy_template_vars = optional(map(string), {})
    policy_statement     = optional(string, null)
  }))
  default = [
    {
      name                 = "ec2-access"
      path                 = null
      desc                 = "Grants full access to EC2 resources"
      policy_template_file = "../../policy-documents/ec2-full-access-policy.tpl"
    }
  ]
}

variable "policies_tags" {
  description = "Tags to apply to IAM policies."
  type        = map(string)
  default     = {}
}

variable "use_root_path_template" {
  description = "Enable or disable use of the root path for policy templates."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------------------
# IAM Role Variables
# -----------------------------------------------------------------------------------------
variable "roles" {
  description = "List of IAM roles to create."
  type = list(object({
    name        = string
    path        = string
    desc        = string
    trust_policy = object({
      policy_template_file = string
      policy_template_vars = map(string)
    })
    policies        = optional(list(string), [])
    inline_policies = optional(list(object({
      name                 = string
      policy_template_file = optional(string, null)
      policy_template_vars = optional(map(any), {})
      policy_statement     = optional(string, null)
    })), [])
    policy_arns = optional(list(string), [])
  }))
  default = [
    {
      name = "ec2-access"
      path = "/"
      desc = "Allow BuildPiper to access EC2 resources"
      trust_policy = {
        policy_template_file = "../../policy-documents/assume-role-trust.tpl"
        policy_template_vars = {
          assume_type         = "user"                        # OR "user"
        assume_name         = "aayush"             # Name of the IAM user/role to trust
        account_id  = "509633460021" 
        }
      }
      policies    = ["ec2-access"]
      policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  ]
}

variable "roles_tags" {
  description = "Tags to apply to IAM roles."
  type        = map(string)
  default     = {}
}

variable "permissions_boundaries" {
  description = "Optional permissions boundary ARNs to attach to roles."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------------------
# Defaults for Policies and Roles
# -----------------------------------------------------------------------------------------
variable "policy_path" {
  description = "Default path for IAM policies."
  type        = string
  default     = "/"
}

variable "policy_desc" {
  description = "Default description for IAM policies."
  type        = string
  default     = ""
}

variable "role_path" {
  description = "Default path for IAM roles."
  type        = string
  default     = "/"
}

variable "role_desc" {
  description = "Default description for IAM roles."
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "Maximum IAM role session duration in seconds (1 to 12 hours)."
  type        = number
  default     = 3600
}

variable "force_detach_policies" {
  description = "Force detach policies before role deletion."
  type        = bool
  default     = null
}

# -----------------------------------------------------------------------------------------
# Feature Toggles
# -----------------------------------------------------------------------------------------
variable "create_iam_policies" {
  description = "Whether to create IAM policies defined in `policies`."
  type        = bool
  default     = true
}

variable "create_iam_roles" {
  description = "Whether to create IAM roles defined in `roles`."
  type        = bool
  default     = true
}

variable "attach_policy_arns" {
  description = "Whether to attach existing policy ARNs to roles."
  type        = bool
  default     = true
}

variable "attach_inline_policies" {
  description = "Whether to attach inline policies to roles."
  type        = bool
  default     = true
}

variable "owner" {
  type = string
  default = "opstree"
}