# Lacework-FortiCNAPP-Agentless-Snapshot-Deleter for AWS
![forticnapp](./img/forticnapp.png)


## Overview
Lacework Agentless scanning creates instance snapshots for filesystem scanning in AWS and removes the snapshots post-analysis after a set period of time. You may choose to more frequently scan for any Agentless snapshots created by Lacework and remove them on a recurring basis for cost optimization. Optionally, you could use the script for the periodic removal of non-Lacework snapshots as well. Simply update the tags.

The Terraform module creates an IAM role for AWS Lambda and attaches a policy to describe and delete snapshots. The lambda function runs per region and identifies applicable snapshots based on Lacework Agentless tags. The Lambda runs daily via cron job and looks for snapshots older than 7 days to be deleted.  

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
