#!/usr/bin/env sh
source $(dirname "$0")/helpers/shared_secrets.sh
TERRAFORM_STATE_S3_KEY="${TERRAFORM_STATE_S3_KEY?Please provide a S3 key to store TF state in.}"
TERRAFORM_STATE_S3_BUCKET="${TERRAFORM_STATE_S3_BUCKET?Please provide a S3 bucket to store state in.}"
TERRAFORM_OUTPUTS_TO_STORE="${TERRAFORM_OUTPUTS_TO_STORE:-app_account_sk app_account_ak certificate_arn}"
AWS_REGION="${AWS_REGION?Please provide an AWS region.}"
ENVIRONMENT="${ENVIRONMENT:-test}"

set -e
action=$1
shift

terraform init --backend-config="bucket=${TERRAFORM_STATE_S3_BUCKET}" \
  --backend-config="key=${TERRAFORM_STATE_S3_KEY}/${ENVIRONMENT}" \
  --backend-config="region=$AWS_REGION" && \

terraform $action $* && \
  if [ "$action" == "apply" ]
  then
    mkdir -p ./secrets
    for output_var in ${TERRAFORM_OUTPUTS_TO_STORE}
    do
      write_secret "$(terraform output "$output_var")" "$output_var"
    done
  fi
