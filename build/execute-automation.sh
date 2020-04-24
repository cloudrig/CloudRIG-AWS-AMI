#!/bin/bash

set -e

STACK_NAME="cloudrig-amifactory-pipeline"
SSM_AUTOMATION_DOCUMENT_NAME=$(aws cloudformation describe-stack-resource --stack-name "$STACK_NAME" --logical-resource-id  BuildAMISSMAutomation | jq -r '.StackResourceDetail.PhysicalResourceId')
aws ssm start-automation-execution --document-name "$SSM_AUTOMATION_DOCUMENT_NAME"
