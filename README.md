# HA-Terraform-Azure
An Azure infrastructure deployment project using Terraform, featuring load balancing and two virtual machines with customized initialization scripts for setting up static websites.


# Azure Infrastructure Deployment with Terraform

Azure Infrastructure Deployment with Terraform is a project that showcases the automated deployment of an Azure infrastructure using Terraform. It provisions a load balancer and deploys two virtual machines, each with customized initialization scripts for hosting static websites. This project simplifies the process of setting up and managing a scalable infrastructure on Azure, enabling efficient hosting of static web content. Explore the code and deployment instructions to quickly get started with deploying your own Azure infrastructure using Terraform.

## Prerequisites

- Azure subscription
- Terraform installed

## Getting Started

1. Clone the repository:

```plaintext
git clone https://github.com/R-D-Y/HA-Terraform-Azure.git
```


Navigate to the project directory:

```plaintext
cd your-repo
```


Initialize Terraform:

```plaintext
terraform init
```


Review and modify the Terraform configuration files according to your requirements. (Like your subscription ID for example)

Creates an execution plan:

```plaintext
terraform plan
```

Deploy the infrastructure:

```plaintext
terraform apply
```

## Access your deployed resources and start using them.

Custom Initialization Scripts
The first virtual machine executes a script that sets up an Nginx server and deploys a static website from HTML-PAGE-NODE-2.html.
The second virtual machine executes a script that installs Nginx and deploys a static website from HTML-PAGE-NODE-1.html.
Feel free to modify the initialization scripts or replace them with your own.

## Cleanup
To remove the deployed infrastructure, run:

```plaintext
terraform destroy --auto-approve
```

**Note:** This will permanently delete all resources created by this project.

# License
This project is licensed under the MIT License.
