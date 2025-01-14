{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowToCreateNetworkSkeleton",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:CreateSubnet",
        "ec2:DescribeVpcs",
        "ec2:DescribeAvailabilityZones"
      ],
      "Resource": "*"
    }
  ]
}