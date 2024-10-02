import boto3
import datetime
import os
import json
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

def lambda_handler(event, context):
    # Get the AWS region
    aws_region = os.environ['AWS_REGION']

    # Ec2 client initialize
    ec2 = boto3.client('ec2', region_name=aws_region)

    # Get current date
    now = datetime.datetime.now(datetime.timezone.utc)

    # Set threshold to 7 days
    delete_time = now - datetime.timedelta(days=7)

    # Get list of snapshots
    snapshots = ec2.describe_snapshots(OwnerIds=['self'])['Snapshots']

    # Initialize a list to collect applicable snapshots
    applicable_snapshots = []

    # Print all snapshots in the region
    if snapshots:
        logger.info(f"Snapshots in region {aws_region}:")
        for snapshot in snapshots:
            snapshot_time = snapshot['StartTime']
            snapshot_id = snapshot['SnapshotId']
            # Check if snapshot is older than 7 days
            if snapshot_time < delete_time:
                # Check for tags
                if 'Tags' in snapshot:
                    for tag in snapshot['Tags']:
                        if tag['Key'] == 'LWTAG_LACEWORK_AGENTLESS' and tag['Value'] == '1':
                            applicable_snapshots.append(snapshot)  # Add to the list of applicable snapshots
                            logger.info(f"Deleting snapshot {snapshot_id} created on {snapshot_time} with tag {tag['Key']}:{tag['Value']}")

                            # Attempt to delete the snapshot
                            try:
                                ec2.delete_snapshot(SnapshotId=snapshot_id)
                            except Exception as e:
                                logger.error(f"Error deleting snapshot {snapshot_id}: {str(e)}")
                else:
                    logger.info(f"Skipping snapshot {snapshot_id} created on {snapshot_time} (no matching tags)")
        # Print applicable snapshots
        if applicable_snapshots:
            logger.info(f"Applicable snapshots for deletion: {len(applicable_snapshots)}")
            for snapshot in applicable_snapshots:
                logger.info(f" - Snapshot ID: {snapshot['SnapshotId']}, Created on: {snapshot['StartTime']}, Tags: {snapshot.get('Tags', 'No tags')}")
        else:
            logger.info(f"No applicable snapshots found for deletion.")
    else:
        logger.info(f"No snapshots found in region {aws_region}.")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Snapshot retrieval completed.',
            'foundSnapshots': len(snapshots),
            'applicableSnapshots': len(applicable_snapshots)
        })
    }



