#!/usr/bin/env bash
aws --region $(cat secrets/aws_sqs_region) sqs purge-queue --queue-url $(cat secrets/sqs_queue_url)
