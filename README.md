# aws-iam-key-rotation

This is a script for rotating AWS Access/Secret Key for MFA users. It is meant to be ran on the user side; because it is much easier to scale when each user can rotate their own keys.

Following assumptions

- User has a `force-mfa` policy that only allows him to rotate keys if authenticated via a MFA session
- User does not have AWS console access

## Quick start

```
./aws-rotate-iam-key-mfa.sh <PROFILE_NAME>
```

| Input        | Description                        |
| ------------ | ---------------------------------- |
| PROFILE_NAME | profile name in your ~/.aws/confg  |

Inspired by https://github.com/rhyeal/aws-rotate-iam-keys
