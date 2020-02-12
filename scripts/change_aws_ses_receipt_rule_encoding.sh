#!/usr/bin/env sh
# This script is required because Terraform can't set SNS email encodings at this time
# of writing and we need emails sent to parking-bot to be Base64 encoded to preserve
# magical HTML stuff.

payload=$(cat <<-JSON
{
    "Name": "$(cat secrets/ses_rule_name)",
    "Recipients": [
        "${TF_VAR_email_address_for_inbound_passport_parking_codes}"
    ],
    "Enabled": true,
    "ScanEnabled": false,
    "Actions": [
        {
            "SNSAction": {
                "TopicArn": "$(cat secrets/sns_topic_arn)",
                "Encoding": "Base64"
            }
        }
    ],
    "TlsPolicy": "Optional"
}
JSON
)
aws --region $(cat secrets/aws_ses_region) ses update-receipt-rule \
  --rule-set-name $(cat secrets/ses_rule_set_name) \
  --rule "$payload"
