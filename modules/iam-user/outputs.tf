output "user_names" {
  description = "Names of IAM users created by Terraform"

  value = [
    for user in aws_iam_user.new_users : user.name
  ]
}
