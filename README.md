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

## **📂 Project Structure**
