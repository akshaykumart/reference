#### IAM USER ###      //iam.tf

module "iam_user" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-user"
  version                       = "~> 5.0"
  for_each                      = toset(var.users)
  name                          = each.value
  force_destroy                 = true
  password_reset_required       = false
  create_iam_user_login_profile = true
  create_iam_access_key         = true
}

### IAM GROUP WITH POLICY ###  //iam.tf

module "iam_group_with_policies" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 5.0"

  name = "group_name"

  group_users = var.users

  attach_iam_self_management_policy = false

  custom_group_policy_arns = [
    data.aws_iam_policy_document.retool-stage.json
  ]
}

### IAM VARIABLES ###   //variables.tf

variable "users" {
  default = [
    "user1",
    "user2",
  ]
}


### IAM POLICY ###    //data.tf

data "aws_iam_policy" "cloudwatch_read_only" {
  name = "CloudWatchReadOnlyAccess"
}

data "aws_iam_policy_document" "developers" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

}

data "aws_iam_policy" "administrator-access" {
  name = "AdministratorAccess"
}

data "aws_iam_policy" "CloudWatchLogsReadOnlyAccess" {
  name = "CloudWatchLogsReadOnlyAccess"
}

data "aws_iam_policy_document" "retool-stage" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      "${data.terraform_remote_state.backend-staging.outputs.aws_s3_bucket_arn}",
      "${data.terraform_remote_state.backend-staging.outputs.aws_s3_bucket_arn}*",
    ]
  }

}

data "terraform_remote_state" "backend-staging" {
  backend = "s3"
  config = {
    bucket = var.remote-state-bucket
    region = var.remote-state-region
    key    = var.remote-state-key
  }
}

### IAM OUTPUT ###  //outputs.tf

output "iam-users" {
  value = module.iam_user
  sensitive = true
}
