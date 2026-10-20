resource "aws_iam_user" "new_users" {
  for_each = toset(var.iam_usernames)

  name = each.value
  path = "/"
}

resource "aws_iam_user_policy_attachment" "user_policy_attachments" {
  for_each = {
    for pair in setproduct(
      keys(aws_iam_user.new_users),
      var.managed_policy_arns
    ) : "${pair[0]}-${pair[1]}" => {
      user       = pair[0]
      policy_arn = pair[1]
    }
  }

  user       = aws_iam_user.new_users[each.value.user].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_user_policy" "inline_policy" {
  for_each = var.inline_policy_document != null ? aws_iam_user.new_users : {}

  name   = "${each.value.name}-inline-policy"
  user   = each.value.name
  policy = var.inline_policy_document
}
