#!/usr/bin/env bash

function rotate() {
  PROFILE_NAME=$1

  export AWS_PAGER=""

  echo "Start IAM key rotation for MFA user"

  echo "Verifying credentials"
  KEY_COUNT=$(AWS_PROFILE=$PROFILE_NAME aws iam list-access-keys --output json | jq '.AccessKeyMetadata | length' || exit 1)
  if [[ "$KEY_COUNT" -gt "1" ]]; then
    echo "You have more than 1 access key. Ensure you only have 1 access key and try again."
    exit 1
  fi
  echo "Verified credentials"

  echo "Creating new access key"
  RESPONSE=$(AWS_PROFILE=$PROFILE_NAME aws iam create-access-key --output json | jq .AccessKey)
  NEW_ACCESS_KEY_ID=$(echo $RESPONSE | jq -r '.AccessKeyId')
  NEW_SECRET_ACCESS_KEY=$(echo $RESPONSE | jq -r '.SecretAccessKey')

  if [[ "$NEW_ACCESS_KEY_ID" != "" && "$NEW_SECRET_ACCESS_KEY" != "" ]]; then
    echo "Created new key $NEW_ACCESS_KEY_ID"

    OLD_ACCESS_KEY_ID=$(aws configure get $PROFILE_NAME.aws_access_key_id)
    OLD_SECRET_ACCESS_KEY=$(aws configure get $PROFILE_NAME.aws_secret_access_key)
    export AWS_ACCESS_KEY_ID=$NEW_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$NEW_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN=""

    echo "-------------------"
    echo "Verifying new access key"
    for i in $(seq 1 20); do
      ERROR=$(aws iam list-access-keys 2>&1 1>/dev/null) && break || sleep 3
    done
    if [[ $ERROR ]]; then
      echo $ERROR >&2
      echo "Removing new key and reverting back to old key"
      export AWS_ACCESS_KEY_ID=$OLD_ACCESS_KEY_ID
      export AWS_SECRET_ACCESS_KEY=$OLD_SECRET_ACCESS_KEY
      aws iam delete-access-key --access-key-id $NEW_ACCESS_KEY_ID
      exit 1
    fi
    echo "Verified new access key"
    echo "-------------------"

    echo "Updating profile: ${PROFILE_NAME}"
    aws configure set aws_access_key_id $NEW_ACCESS_KEY_ID --profile ${PROFILE_NAME}
    aws configure set aws_secret_access_key $NEW_SECRET_ACCESS_KEY --profile ${PROFILE_NAME}

    echo "Deleting old access key"
    aws iam delete-access-key --access-key-id $OLD_ACCESS_KEY_ID --no-paginate

    echo "Deleted old key $OLD_ACCESS_KEY_ID"

    echo "Key rotated successfully!"
    exit 0
  else
    echo "Failed to create access key. Please correct reported errors and try again." >&2
    exit 1
  fi
}

rotate $1