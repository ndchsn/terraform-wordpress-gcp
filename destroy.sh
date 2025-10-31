#!/bin/bash

# WordPress Cleanup Script
# This script destroys all resources created by Terraform

set -e  # Exit on any error

echo "🗑️  WordPress Infrastructure Cleanup..."

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

# Navigate to terraform directory
cd terraform

print_warning "⚠️  WARNING: This will PERMANENTLY DELETE all resources!"
print_warning "This includes:"
echo "  - Virtual Machine and all data"
echo "  - VPC and networking components"
echo "  - Firewall rules"
echo "  - All WordPress content and database"
echo ""
print_error "This action CANNOT be undone!"
echo ""
print_warning "Are you absolutely sure you want to continue? (type 'yes' to confirm)"
read -r response

if [[ "$response" != "yes" ]]; then
    print_status "Cleanup cancelled. No resources were deleted."
    exit 0
fi

print_status "Planning destruction..."
terraform plan -destroy

print_warning "Last chance! Proceed with destruction? (type 'DELETE' to confirm)"
read -r final_response

if [[ "$final_response" != "DELETE" ]]; then
    print_status "Cleanup cancelled. No resources were deleted."
    exit 0
fi

print_status "Destroying infrastructure..."
terraform destroy -auto-approve

print_success "All resources have been successfully destroyed!"
print_status "Cleanup completed. Your GCP project is now clean."