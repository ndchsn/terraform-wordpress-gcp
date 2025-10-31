#!/bin/bash

# WordPress Deployment Script
# This script automates the entire deployment process

set -e  # Exit on any error

echo "🚀 Starting WordPress deployment on GCP..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform.tfvars exists
if [ ! -f "terraform/terraform.tfvars" ]; then
    print_error "terraform.tfvars not found!"
    print_status "Please copy terraform.tfvars.example to terraform.tfvars and configure it"
    echo "cd terraform && cp terraform.tfvars.example terraform.tfvars"
    exit 1
fi

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    print_error "Not authenticated with gcloud!"
    print_status "Please run: gcloud auth login && gcloud auth application-default login"
    exit 1
fi

# Navigate to terraform directory
cd terraform

print_status "Initializing Terraform..."
terraform init

print_status "Validating Terraform configuration..."
terraform validate

print_status "Planning Terraform deployment..."
terraform plan

print_warning "This will create resources in GCP. Continue? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled."
    exit 0
fi

print_status "Applying Terraform configuration..."
terraform apply -auto-approve

print_success "Infrastructure deployed successfully!"

# Get outputs
VM_IP=$(terraform output -raw vm_external_ip)
WORDPRESS_URL=$(terraform output -raw wordpress_url)

print_success "Deployment completed!"
echo ""
echo "📋 Deployment Information:"
echo "=========================="
echo "VM IP Address: $VM_IP"
echo "WordPress URL: $WORDPRESS_URL"
echo "SSH Command: ssh ubuntu@$VM_IP"
echo ""
print_warning "Note: WordPress may take 5-10 minutes to be fully ready."
print_status "You can check the startup progress with:"
echo "ssh ubuntu@$VM_IP 'sudo tail -f /var/log/startup-script.log'"
echo ""
print_success "🎉 Happy WordPressing!"