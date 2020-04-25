#!/bin/bash

set -e

BUCKET_NAME="cloudrig-amifactory"
STACK_NAME="cloudrig-amifactory-pipeline"

#
#  Cleanup
#
rm -rf dist

#
#  Prepare
#
mkdir -p dist
VERSION=$(cat './VERSION')

#
#  Test
#

for filename in $(find 'cfn/' -name '*.yml'); do
    aws cloudformation validate-template --template-body "file://$filename"
done

#
#  Package
#
#  - templates
cp -r cfn dist/cfn

#  - CloudRIG Windows install scripts
mkdir -p dist/cloudrig-windows-install/
cp -r scripts/ dist/cloudrig-windows-install/
(
  set -e
  cd dist/cloudrig-windows-install/
  zip -r cloudrig-windows-install.zip *
  cd ..
  mv cloudrig-windows-install/cloudrig-windows-install.zip .
  rm -rf cloudrig-windows-install/
)

#
#  Deploy
#
aws s3 sync --delete dist "s3://$BUCKET_NAME/v$VERSION/"
aws s3 sync --delete dist "s3://$BUCKET_NAME/latest/"


IS_FIRST_CREATION=false
aws cloudformation describe-stacks --stack-name $STACK_NAME || IS_FIRST_CREATION=true
if [[ "$IS_FIRST_CREATION" == "true" ]]; then
  echo "Creating the stack $STACK_NAME..."
  aws cloudformation create-stack --stack-name $STACK_NAME --template-url "https://$BUCKET_NAME.s3-eu-west-1.amazonaws.com/v$VERSION/cfn/template-golden-ami-pipeline.yml" --parameters "ParameterKey=Version,ParameterValue=$VERSION" --capabilities CAPABILITY_NAMED_IAM
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
else
  echo "Updating the stack $STACK_NAME..."
  aws cloudformation update-stack --stack-name $STACK_NAME --template-url "https://$BUCKET_NAME.s3-eu-west-1.amazonaws.com/v$VERSION/cfn/template-golden-ami-pipeline.yml" --parameters "ParameterKey=Version,ParameterValue=$VERSION" --capabilities CAPABILITY_NAMED_IAM
  aws cloudformation wait stack-update-complete --stack-name $STACK_NAME
fi