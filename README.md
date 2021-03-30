# aws-iam-key-rotation

This is a script for rotating AWS Access/Secret Key for (non)MFA users. It is meant to be ran on the user side; because it is much easier to scale when each user can rotate their own keys.

Following assumptions

- User does not have AWS console access (else just use the console)

## Quick start

```
./aws-rotate-iam-key-mfa.sh <PROFILE_NAME>
```

| Input        | Description                        |
| ------------ | ---------------------------------- |
| PROFILE_NAME | profile name in your ~/.aws/confg  |

Inspired by https://github.com/rhyeal/aws-rotate-iam-keys


## Required policies
In order for the user to manage their own access keys, you need either policies applied on the user. 
**Recommend**: using the MFA as the default. 

### With MFA
For use with `aws-rotate-iam-key-mfa.sh`

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IAMAccessKeyMFA",
      "Effect": "Allow",
      "Action": [
        "iam:DeleteAccessKey",
        "iam:UpdateAccessKey",
        "iam:CreateAccessKey",
        "iam:ListAccessKeys"
      ],
      "Resource": "arn:aws:iam::*:user/${aws:username}",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "true"
        },
        "NumericLessThan": {
          "aws:MultiFactorAuthAge": 3600
        }
      }
    }
  ]
}
```


### Without MFA
For use with `aws-rotate-iam-key.sh`

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IAMAccessKey",
      "Effect": "Allow",
      "Action": [
        "iam:DeleteAccessKey",
        "iam:UpdateAccessKey",
        "iam:CreateAccessKey",
        "iam:ListAccessKeys"
      ],
      "Resource": "arn:aws:iam::*:user/${aws:username}"
    }
  ]
}
```