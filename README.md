# Lacework-FortiCNAPP-Agentless-Snapshot-Deleter
![forticnapp](./img/Overview.png)


## Overview
Lacework Agentless scanning creates instance snapshots for filesystem scanning but does not remove the snapshots post-analysis. The Terraform module creates an IAM role for AWS Lambda and attaches a policy to describe and delete snapshots. The lambda function runs per region and identifies applicable snapshots based on Lacework Agentless tags. The Lambda runs daily via cron job and looks for snapshots older than 7 days to be deleted.  

## Requirements

1. AWS CLI or Cloud shell  
2. Terraform installed  

## Deployment
1. Zip the lambda python file to lambda_function_payload.zip
2. Make sure the zip file is in the same directory as the terraform files
3. Terraform init
4. Terraform validate
5. Terraform apply
