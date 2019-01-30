# Stack-infrastructure

Service catalog infrastructure stack

This stack will create Amazon vpc, a bastion ec2 server and various components you might require to deploy other stacks in production.

Giving an overview of components available :

  * AWS S3 bucket to upload backups
  * AWS S3 bucket to upload deployment artefacts
  * AWS SSH key pair
  * AWS EC2 bastion server
  * AWS VPCs and subnets
  * AWS SES service to allow your EC2 servers send system mails
  * AWS IAM roles and admin policies

> **Pipeline** The pipeline contains a manual approval between terraform plan and terraform apply.
> That means if you trigger a terraform plan, to apply it, you have to go on terraform apply job
> and click on the `+` button to trigger it.

# Requirements

In order to run this task, couple elements are required within the infrastructure:

* Having an S3 bucket for terraform remote states

# Job description

## Overview

**terraform-plan:**
Terraform job that will simply make a plan of the infrastructure's stack.

**terraform-apply:**
Terraform job similar to the plan one, but will actually create/update everything that needs to. Please see the plan diff for a better understanding.

**app-deploy-front:**
Ansible job meant to configure Amazon EC2 server used as bastion.
