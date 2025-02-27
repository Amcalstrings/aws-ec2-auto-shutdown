# AWS EC2 Auto Shutdown with Lambda & CloudWatch

## 🚀 Overview
This AWS Lambda function automatically stops low-utilized EC2 instances using CloudWatch metrics.

## 🔧 How It Works
1. A **CloudWatch EventBridge Rule** triggers the Lambda function periodically.
2. The function checks **EC2 instances' CPU utilization**.
3. If an instance has **low CPU usage**, it is automatically **stopped**.

## 🛠 Technologies Used
- **AWS Lambda** (Python)
- **Amazon CloudWatch**
- **Amazon EC2**
- **Amazon SNS** (optional for notifications)

## 📂 Setup Instructions
1. Deploy the Lambda function using the provided Python script.
2. Set up **IAM roles** with the required permissions.
3. Configure **EventBridge** to trigger the function periodically.

## 📜 Code
```python
# Example snippet
ec2_client.stop_instances(InstanceIds=instances_to_stop)
