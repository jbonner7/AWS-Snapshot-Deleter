# Snapshot-Deleter for AWS
![image](https://github.com/user-attachments/assets/31038ce7-7729-4c29-8d4a-ba5d4db527ea)



## Overview
Resource management in the cloud plays an important role not just in the security of your cloud environment, but for cost optimization as well. The script can be used for the periodic removal of EBS snapshots. Simply update the tags in the Lambda python script. The Terraform module creates an IAM role for AWS Lambda and attaches a policy to describe and delete snapshots. The lambda function runs per region and identifies applicable snapshots based on AWS tags. The Lambda runs daily via cron job and looks for snapshots older than 7 days to be deleted.  

## Requirements

1. AWS CLI or Cloud shell  
2. Terraform installed  

## Deployment
1. Zip the lambda python file to lambda_function_payload.zip
2. Make sure the zip file is in the same directory as the terraform files
3. Terraform init
4. Terraform validate
5. Terraform apply

You should see a message like below to validate the applicable images have been identified and removed. 

![image](https://github.com/user-attachments/assets/a84565b4-6570-49d9-9194-7a6211b82d0b)
