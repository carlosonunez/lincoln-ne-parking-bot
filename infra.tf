terraform {
  backend "s3" {}
}

# SES is not supported in 'us-east-2'.
provider "aws" {
  region = "us-east-1"
}

locals {
  app_iam_user_name = "parking-bot"
  sqs_queue_name = "ppprk-codes"
  sns_topic_name = "parking_bot_code_notifications"
  ses_rule_set_name = "parking-bot-rule-set"
  ses_receipt_rule_name = "parking_bot_verification_codes_rule"
}

variable "email_address_for_inbound_passport_parking_codes" {}

data "aws_caller_identity" "me" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "iam_user" {
  statement {
    sid = "1"
    effect = "Allow"
    actions =  [ "sqs:ReceiveMessage", "sqs:GetQueueUrl" ]
    resources = [ aws_sqs_queue.passport_parking_verification_codes_queue.arn ]
  }
}

data "aws_iam_policy_document" "sns-sqs-connector" {
  policy_id = "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:${local.sqs_queue_name}/SQSDefaultPolicy"
  statement {
    sid = "sqs-sns-connector"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SQS:SendMessage"
    ]
    resources = [
      "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:${local.sqs_queue_name}"
    ]
    condition {
      test = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        "${aws_sns_topic.inbound_passport_parking_code_notifications.arn}"
      ]
    }
  }
}

resource "aws_iam_user" "parking_bot" {
  name = local.app_iam_user_name
  tags = {
    GITHUB_PROJECT = "https://github.com/carlosonunez/parking-bot"
  }
}

resource "aws_iam_policy" "parking_bot" {
  name = local.app_iam_user_name
  path = "/"
  description = "Provides access to the Passport Parking verification codes SQS queue."
  policy = "${data.aws_iam_policy_document.iam_user.json}"
}

resource "aws_iam_policy_attachment" "parking_bot" {
  name = "parking_bot_policy_attachment"
  users = [ aws_iam_user.parking_bot.name ]
  policy_arn = aws_iam_policy.parking_bot.arn
}

resource "aws_ses_receipt_rule_set" "parking_bot_code_emails" {
  rule_set_name = local.ses_rule_set_name
}

resource "aws_ses_active_receipt_rule_set" "parking_bot_code_emails" {
  rule_set_name = local.ses_rule_set_name
}

resource "aws_ses_receipt_rule" "parking_bot_code_emails_rule" {
  name = local.ses_receipt_rule_name
  rule_set_name = local.ses_rule_set_name
  recipients = [var.email_address_for_inbound_passport_parking_codes]
  enabled = true
  sns_action {
    topic_arn = aws_sns_topic.inbound_passport_parking_code_notifications.arn
    position = 1
  }
}

resource "aws_iam_access_key" "parking_bot" {
  user = aws_iam_user.parking_bot.name
}

resource "aws_sns_topic" "inbound_passport_parking_code_notifications" {
  name = local.sns_topic_name
}

resource "aws_sqs_queue" "passport_parking_verification_codes_queue" {
  name = local.sqs_queue_name 
  policy = "${data.aws_iam_policy_document.sns-sqs-connector.json}"
}

resource "aws_sns_topic_subscription" "code_notifications_to_queue_connector" {
  topic_arn = aws_sns_topic.inbound_passport_parking_code_notifications.arn
  protocol = "sqs"
  endpoint = aws_sqs_queue.passport_parking_verification_codes_queue.arn
}

output "app_account_ak" {
  value = aws_iam_access_key.parking_bot.id
}

output "app_account_sk" {
  value = aws_iam_access_key.parking_bot.secret
}

output "ses_rule_set_name" {
  value = local.ses_rule_set_name
}

output "ses_rule_name" {
  value = local.ses_receipt_rule_name
}

output "aws_sqs_region" {
  value = data.aws_region.current.name
}

output "aws_ses_region" {
  value = data.aws_region.current.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.inbound_passport_parking_code_notifications.arn
}
