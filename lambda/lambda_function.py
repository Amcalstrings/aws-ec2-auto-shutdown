import json
import boto3
import datetime
from datetime import timedelta
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

#Initialize AWS clients
ec2_client = boto3.client("ec2")
cloud_watch_client = boto3.client("cloudwatch")
sns_client = boto3.client("sns")

SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:717279705656:EC2ShutDownAlerts"
CPU_THRESHOLD = 7
MONITOR_PERIOD = 600 # measured in seconds

def get_low_utilized_instances():
    #fetch ec2 instances with low cpu utilization
    try:
        instances_to_stop = []
        response = ec2_client.describe_instances(Filters=[{"Name": "instance-state-name", "Values": ["running"]}])
        for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                instance_id = instance["InstanceId"]

                #get cpu utilization 
                cpu_response = cloud_watch_client.get_metric_statistics(
                    Namespace="AWS/EC2",
                    MetricName="CPUUtilization",
                    Dimensions=[{"Name": "InstanceId", "Value": instance_id}],
                    StartTime=datetime.datetime.utcnow() - datetime.timedelta(seconds=MONITOR_PERIOD),
                    EndTime=datetime.datetime.utcnow(),
                    Period=MONITOR_PERIOD,
                    Statistics=["Average"]
                )

                #check if utilization is below threshhold
                if cpu_response.get('Datapoints'):
                    latest_datapoint = sorted(cpu_response['Datapoints'], key=lambda x: x['Timestamp'])[-1]
                    cpu_utilization = latest_datapoint['Average']
                    
                    print(f"Instance {instance_id} CPU Usage: {cpu_utilization}%")

                    if cpu_utilization < CPU_THRESHOLD:
                        instances_to_stop.append(instance_id)
                else:
                    print(f"Instance {instance_id} has NO CPU data in CloudWatch!")
        print(f"instances to stop: {instances_to_stop}")
        return instances_to_stop
    
    except Exception as e:
        logger.error(f"Error fetching low utilization instances: {str(e)}")
        return []

def stop_instances(instance_ids):
    if instance_ids:
        try:
            print(f"Stopping instances: {instance_ids}")
            ec2_client.stop_instances(InstanceIds=instance_ids)
            sns_client.publish(
                TopicArn="arn:aws:sns:us-east-1:717279705656:EC2ShutDownAlerts",
                Subject="EC2 Instance Stopped",
                Message=f"EC2 Instance {instance_ids} has been stopped due to low CPU utilization"
            )
            logger.info(f"Stopped instances: {instance_ids}")
        except Exception as e:
            logger.error(f"Error stopping instances: {str(e)}")



def lambda_handler(event, context):
    instances = get_low_utilized_instances()
    if instances:
        stop_instances(instances)
    return {
        'statusCode': 200,
        'body': f'Checked instances. Stopped: {instances}'
    }
