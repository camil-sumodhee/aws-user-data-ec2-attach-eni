# aws-user-data-ec2-attach-eni
User data shell script to have an AWS EC2 instance attach an existing ENI (Elastic Network Interface) at creation time.
This script is intented for Ubuntu machines as it also configures the new interface. Amazon linuz instances do not need this extra config step.

# Requirements

- **IAM**: The EC2 instance must be authorized to attach the ENI. Make sure you assign it the right role. Below an example of IAM permissions required.
- **OS**: Currently this script OS target is Ubuntu 16.04. Not tested outside this target.

# IAM permissions

Create an EC2 instance role and attach the following policy document

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllAttachENI",
            "Effect": "Allow",
            "Action": [
                "ec2:DetachNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:AttachNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
```



