# **AWS EC2 Auto Shutdown with Terraform & GitHub Actions 🚀**

## **📌 Overview**
This project automates the shutdown of **underutilized EC2 instances** based on **CPU usage**. The automation is implemented using **AWS Lambda, CloudWatch, SNS, and API Gateway**, all provisioned via **Terraform**.

Additionally, a **CI/CD pipeline using GitHub Actions** ensures that updates to the Lambda function are automatically deployed.

---

## **🛠 Features**
✅ **AWS Lambda** - Monitors CPU usage & stops idle instances  
✅ **CloudWatch EventBridge** - Triggers Lambda every 10 minutes  
✅ **SNS Notifications** - Alerts when an instance is stopped  
✅ **API Gateway** - Provides a manual HTTP trigger to stop instances  
✅ **Terraform Infrastructure as Code** - Manages AWS resources  
✅ **GitHub Actions CI/CD** - Automates Lambda function updates  

---


---

## **🚀 Deployment Guide**
### **🔹 Prerequisites**
- **AWS CLI** installed & configured  
- **Terraform** installed  
- **Git & GitHub** setup  

### **🔹 Setup & Deployment**
1️⃣ **Clone the repository**  
```sh
git clone https://github.com/your-username/aws-ec2-auto-shutdown.git
cd aws-ec2-auto-shutdown

2️⃣ Initialize Terraform
terraform init

3️⃣ Apply Terraform to deploy resources
terraform apply --auto-approve
This will provision:
EC2 instances
AWS Lambda function
IAM roles & permissions
CloudWatch rules
SNS topic
API Gateway

4️⃣ Manually trigger the Lambda (Optional)
Use the API Gateway endpoint:
curl -X POST https://your-api-gateway-url/stop-instances

🛠 CI/CD Pipeline (GitHub Actions)
This project includes GitHub Actions to automatically update the Lambda function when changes are pushed.

🔹 Setup GitHub Secrets
Go to GitHub → Your Repo → Settings → Secrets → Actions and add:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION

🔹 How CI/CD Works
✅ Any push to the main branch triggers GitHub Actions
✅ It zips the Lambda function
✅ It uploads the new Lambda function to AWS
✅ It updates the Lambda function automatically

⚠️ Cleanup
To destroy all AWS resources, run:
terraform destroy --auto-approve

📜 License
This project is open-source and licensed under the MIT License.





