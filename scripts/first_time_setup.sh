#!/usr/bin/env bash
SERVERLESS_BUCKET_NAME="${SERVERLESS_BUCKET_NAME?Please provide a bucket for Serverless stuff.}"
TERRAFORM_STATE_S3_BUCKET="${TERRAFORM_STATE_S3_BUCKET?Please provide a bucket for Terraform stuff.}"
TF_VAR_app_name="${TF_VAR_app_name?Please define the 'app_name' Terraform variable with TF_VAR_app_name.}"

get_application_name() {
  echo "$TF_VAR_app_name" | tr '[:upper:]' '[:lower:]'
}

make_buckets() {
  for bucket in "$SERVERLESS_BUCKET_NAME" "$TERRAFORM_STATE_S3_BUCKET"
  do
    if ! aws --region=$AWS_REGION s3 ls "s3://$bucket" &>/dev/null
    then
      aws --region=$AWS_REGION s3 mb "s3://$bucket"
    fi
  done
}

create_test_mocks_file() {
  if ! test -f spec/include/mocks.yml
  then
    mkdir -p spec/include &&
    cat >spec/include/mocks.yml <<-EXAMPLE_MOCK_FILE
---
- url: 'http://example.page'
  page: '/path/to/page/within/spec/fixtures/path'
EXAMPLE_MOCK_FILE
  >&2 echo "INFO: Test mocks file created. Be sure to replace the example mocks \
therein."
  fi
}

create_spec_helper_file() {
  if ! test -f spec/spec_helper.rb
  then
    mkdir -p spec &&
    cat >spec/spec_helper.rb <<-SPEC_HELPER
require 'yaml'
require 'httparty'
require '$(get_application_name)'

module TestMocks
  def self.generate!
    extend RSpec::Mocks::ExampleMethods
    YAML.safe_load(File.read('spec/include/mocks.yml'),
                   symbolize_names: true).each do |mock|
      allow(HTTParty)
        .to receive(:get)
        .with(mock[:url], follow_redirects: false)
        .and_return(double(HTTParty::Response,
                           code: 200,
                           body: File.read("spec/fixtures/#{mock[:page]}")))
    end
  end
end
SPEC_HELPER
  >&2 echo "INFO: spec/spec_helper.rb created. Be sure to include \
\"require 'spec_helper'\" at the top of your specs."
  fi
}

create_library() {
  if ! test -f lib/$(get_application_name).rb
  then
    mkdir -p lib/$(get_application_name) &&
      touch lib/$(get_application_name).rb
    >&2 echo "INFO: Skeleton for application created."
  fi
}

make_buckets &&
  create_test_mocks_file &&
  create_spec_helper_file &&
  create_library
