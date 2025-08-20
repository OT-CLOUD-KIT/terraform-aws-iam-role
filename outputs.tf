output "role" {
  description = "Roles details"
  value       = {
    "id"    = [for iam_role in aws_iam_role.roles : iam_role.id],
    "name"  = [for iam_role in aws_iam_role.roles : iam_role.name],
    "arn"   = [for iam_role in aws_iam_role.roles : iam_role.arn],
    "type"  = "iam-role"
  }
}

output "policy" {
  description = "Policies details"
  value       = {
    "id"    = [for iam_policy in aws_iam_policy.policies : iam_policy.id],
    "name"  = [for iam_policy in aws_iam_policy.policies : iam_policy.name],
    "arn"   = [for iam_policy in aws_iam_policy.policies : iam_policy.arn],
    "type"  = "iam-policy"
  }
}

output "roles" {
  description = "ARN of the IAM role"
  value       = [for iam_role in aws_iam_role.roles : { name = iam_role.name, arn = iam_role.arn, description = iam_role.description }]
}

output "policies" {
  description = "ARN of the IAM policies"
  value       = [for iam_policy in aws_iam_policy.policies : { name = iam_policy.name, arn = iam_policy.arn, description = iam_policy.description }]
}

output "aws_iam_role_policy_attachment_output" {
  description = "ARN of the IAM policies"
  value       = [for iam_policy in aws_iam_role_policy_attachment.policy_attachments : { policy_arn = iam_policy.policy_arn  }]
}