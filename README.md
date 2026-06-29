# Devops-Project-Repo
## Project Overview

- This project demonstrates the complete implementation of a modern DevOps workflow for deploying and managing a cloud-native e-commerce application on AWS.
  
- The application consists of multiple microservices that are containerized using Docker and deployed on an Amazon EKS (Elastic Kubernetes Service) cluster.

- The infrastructure is fully provisioned using Terraform, following the Infrastructure as Code (IaC) approach.

- Kubernetes is used as the container orchestration platform, while Helm simplifies the deployment of supporting components such as the AWS Load Balancer Controller.

- To automate software delivery, GitHub Actions is used to implement a Continuous Integration (CI) pipeline that builds, tests, performs code quality checks, creates Docker images, and pushes them to a container registry.

- Continuous Deployment (CD) is implemented using ArgoCD, following the GitOps methodology, where Git serves as the single source of truth for the Kubernetes cluster.
_____
## Objectives

- Containerize microservices using Docker.
- Provision AWS infrastructure using Terraform.
- Deploy a Kubernetes cluster on Amazon EKS.
- Configure Kubernetes Deployments, Services, and Ingress resources.
- Implement Continuous Integration (CI) using GitHub Actions.
- Implement Continuous Deployment (CD) using ArgoCD and GitOps.
- Automate application updates from code commit to production deployment.
- Demonstrate a production-inspired DevOps workflow using industry-standard tools and practices.

