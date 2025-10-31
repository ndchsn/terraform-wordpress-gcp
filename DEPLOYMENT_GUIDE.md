# Step-by-Step Deployment Guide

## Quick Start (Bahasa Indonesia)

### 1. Persiapan Awal
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/terraform-wordpress-gcp.git
cd terraform-wordpress-gcp

# Setup GCP
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud services enable compute.googleapis.com
gcloud auth application-default login
```

### 2. Konfigurasi
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars dengan project ID dan password Anda
```

### 3. Deploy
```bash
# Otomatis (recommended)
chmod +x ../deploy.sh
../deploy.sh

# Manual
terraform init
terraform plan
terraform apply
```

### 4. Akses WordPress
- Tunggu 5-10 menit untuk startup script selesai
- Buka http://VM_IP:8080 di browser
- Setup WordPress sesuai kebutuhan

### 5. Cleanup
```bash
chmod +x ../destroy.sh
../destroy.sh
```

---

## Quick Start (English)

### 1. Initial Setup
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/terraform-wordpress-gcp.git
cd terraform-wordpress-gcp

# Setup GCP
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud services enable compute.googleapis.com
gcloud auth application-default login
```

### 2. Configuration
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project ID and passwords
```

### 3. Deploy
```bash
# Automated (recommended)
chmod +x ../deploy.sh
../deploy.sh

# Manual
terraform init
terraform plan
terraform apply
```

### 4. Access WordPress
- Wait 5-10 minutes for startup script to complete
- Open http://VM_IP:8080 in browser
- Setup WordPress as needed

### 5. Cleanup
```bash
chmod +x ../destroy.sh
../destroy.sh
```

## Common Issues & Solutions

### Issue: "Project not found"
**Solution**: Make sure your project ID is correct in terraform.tfvars

### Issue: "APIs not enabled"
**Solution**: 
```bash
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

### Issue: "Permission denied"
**Solution**: Make sure you have proper IAM roles:
- Compute Admin
- VPC Admin
- Service Account User

### Issue: WordPress not loading
**Solution**: 
1. Wait longer (startup script takes time)
2. Check logs: `ssh ubuntu@VM_IP 'sudo tail -f /var/log/startup-script.log'`
3. Check containers: `ssh ubuntu@VM_IP 'sudo docker ps'`

## Security Best Practices

1. **Change default passwords** in terraform.tfvars
2. **Use strong passwords** (minimum 12 characters)
3. **Limit SSH access** by modifying firewall rules
4. **Enable 2FA** on your GCP account
5. **Regular updates** of Docker images
6. **Monitor access logs** regularly

## Cost Optimization

1. **Use e2-micro** (free tier eligible)
2. **Stop VM** when not needed: `gcloud compute instances stop wordpress-vm --zone=us-central1-a`
3. **Delete unused resources** regularly
4. **Monitor billing** alerts

## Monitoring & Maintenance

### Check VM Status
```bash
gcloud compute instances list
```

### Check Application Logs
```bash
ssh ubuntu@VM_IP
sudo docker-compose -f /home/wordpress-app/docker-compose.yml logs -f
```

### Update WordPress
```bash
ssh ubuntu@VM_IP
cd /home/wordpress-app
sudo docker-compose pull
sudo docker-compose up -d
```

### Backup Database
```bash
ssh ubuntu@VM_IP
sudo docker exec wordpress_db mysqldump -u root -p wordpress > backup.sql
```

## Advanced Configuration

### Custom Domain Setup
1. Point your domain to VM IP
2. Update WordPress URL in admin panel
3. Consider using Cloud Load Balancer for SSL

### SSL Certificate
1. Use Let's Encrypt with nginx-proxy
2. Or use Google Cloud Load Balancer with managed SSL

### Scaling
1. Use Cloud SQL instead of containerized MySQL
2. Use multiple VM instances with Load Balancer
3. Use Cloud Storage for WordPress media files