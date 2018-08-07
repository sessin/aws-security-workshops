#!/bin/bash

PROFILE=default
REGION=us-west-2

while test $# -gt 0; do
  case "$1" in
    -h|--help)
            echo "Cleans up the forensics workshop CloudFormation stacks by deleting the resources and infrastructure that were created."
            echo " "
            echo "options:"
            echo "-h, --help                shows this help"
            echo "-p, --profile PROFILE     specify an AWS CLI profile to use"
            echo "-r, --region REGION       AWS region to use for the specified profile"
            exit 0
            ;;
    -p|--profile)
            shift
            if test $# -gt 0; then
                export PROFILE=$1
            else
                echo "No profile specified"
                exit 1
            fi
            shift
            ;;
    -r|--region)
            shift
            if test $# -gt 0; then
                export REGION=$1
            else
                echo "No region specified"
                exit 1
            fi
            shift
            ;;
    *)
            break
            ;;
  esac
done

# Delete S3 buckets first, otherwise stack deletion will fail
BUCKETS_TO_DELETE=("LogBucket" "DataBucket" "GDThreatListBucket")

for bucket in "${BUCKETS_TO_DELETE[@]}"
do
    bucket_desc=$(aws --profile ${PROFILE} --region ${REGION} cloudformation describe-stack-resource --stack-name "BH2018-AwsForensicsWksp-EnvSetup" --logical-resource-id ${bucket})
    
    if [[ -n ${bucket_desc} ]]; then
        actual_bucket_name=$(python -c "import sys, json;  json.load(${bucket_desc}).get('StackResourceDetail').get('PhysicalResourceId')")
        
        if [[ -n ${actual_bucket_name} ]]; then
            echo "Deleting the S3 bucket ${bucket} (${actual_bucket_name})"
            aws --profile ${PROFILE} --region ${REGION} s3 rb s3://${actual_bucket_name} --force
        fi
    fi
done

STACKS_TO_DELETE=(
    "BH2018-AwsForensicsWksp-EnvSetup"
    "BH2018-AwsForensicsWksp-AttackSim"
)

for stack in "${STACKS_TO_DELETE[@]}"
do
    echo "Deleting the CloudFormation stack ${stack}"
    
    # Delete the stack
    aws --profile ${PROFILE} --region ${REGION} cloudformation delete-stack --stack-name ${stack}

    # Wait for completion
    # (this command didn't exist in older versions of the AWS CLI, so ignore any errors)
    aws --profile ${PROFILE} --region ${REGION} cloudformation wait stack-delete-complete --stack-name ${stack} || true
done
