# WordPress Deployment on Google Cloud Platform

[🇮🇩 Bahasa Indonesia](#bahasa-indonesia) | [🇺🇸 English](#english)

---

## Bahasa Indonesia

### Deskripsi Proyek
Proyek ini menggunakan Terraform untuk membuat infrastruktur di Google Cloud Platform (GCP) dan Docker Compose untuk menjalankan aplikasi WordPress dengan database MySQL. Semua proses instalasi Docker dan deployment aplikasi dilakukan secara otomatis saat VM pertama kali dinyalakan.

### Arsitektur
- **VPC**: Jaringan virtual khusus untuk isolasi keamanan
- **Subnet**: Subnet publik untuk akses internet
- **Firewall**: Aturan keamanan untuk port 22 (SSH) dan 8080 (WordPress)
- **VM**: Instance e2-micro dengan Ubuntu 22.04 LTS
- **Aplikasi**: WordPress + MySQL menggunakan Docker Compose

### Prasyarat
Sebelum memulai, pastikan Anda sudah menginstal:

1. **Terraform** (versi >= 1.0)
   ```bash
   # Download dari https://www.terraform.io/downloads.html
   # Atau gunakan package manager
   ```

2. **Google Cloud SDK (gcloud CLI)**
   ```bash
   # Download dari https://cloud.google.com/sdk/docs/install
   ```

3. **Git**
   ```bash
   # Untuk clone repository
   ```

4. **SSH Key Pair**
   ```bash
   # Buat SSH key jika belum ada
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ```

### Konfigurasi Awal

#### 1. Setup Google Cloud
```bash
# Login ke Google Cloud
gcloud auth login

# Set project ID (ganti dengan project ID Anda)
gcloud config set project YOUR_PROJECT_ID

# Enable APIs yang diperlukan
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Setup Application Default Credentials
gcloud auth application-default login
```

#### 2. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/terraform-wordpress-gcp.git
cd terraform-wordpress-gcp
```

#### 3. Konfigurasi Terraform
```bash
cd terraform

# Copy file konfigurasi
cp terraform.tfvars.example terraform.tfvars

# Edit file terraform.tfvars dengan editor favorit Anda
nano terraform.tfvars
```

Isi file `terraform.tfvars` dengan informasi Anda:
```hcl
project_id = "your-actual-project-id"
region     = "asia-southeast2"
zone       = "asia-southeast2-a"

ssh_user             = "ubuntu"
ssh_public_key_path  = "~/.ssh/id_rsa.pub"

mysql_root_password = "password-root-yang-aman"
mysql_database      = "wordpress"
mysql_user          = "wpuser"
mysql_password      = "password-wp-yang-aman"
```

### Langkah Deployment

#### 1. Inisialisasi Terraform
```bash
cd terraform
terraform init
```

#### 2. Validasi Konfigurasi
```bash
terraform validate
terraform plan
```

#### 3. Deploy Infrastruktur
```bash
terraform apply
```
Ketik `yes` ketika diminta konfirmasi.

#### 4. Tunggu Proses Selesai
Deployment akan memakan waktu sekitar 5-10 menit. Terraform akan:
- Membuat VPC dan subnet
- Membuat firewall rules
- Membuat VM dengan Ubuntu 22.04
- Menginstal Docker dan Docker Compose secara otomatis
- Menjalankan WordPress dan MySQL

### Verifikasi Deployment

#### 1. Cek Output Terraform
```bash
terraform output
```
Anda akan melihat informasi seperti:
- IP address VM
- URL WordPress
- Command SSH

#### 2. Akses WordPress
Buka browser dan kunjungi:
```
http://VM_EXTERNAL_IP:8080
```

#### 3. SSH ke VM (Opsional)
```bash
ssh ubuntu@VM_EXTERNAL_IP
```

Cek status container:
```bash
sudo docker ps
sudo docker-compose -f /home/wordpress-app/docker-compose.yml logs
```

### Troubleshooting

#### Jika WordPress tidak bisa diakses:
1. Tunggu beberapa menit (startup script masih berjalan)
2. Cek log startup script:
   ```bash
   ssh ubuntu@VM_EXTERNAL_IP
   sudo tail -f /var/log/startup-script.log
   ```

#### Jika ada error saat terraform apply:
1. Pastikan project ID benar
2. Pastikan APIs sudah diaktifkan
3. Pastikan credentials sudah di-setup dengan benar

### Cleanup (Hapus Semua Resource)
```bash
cd terraform
terraform destroy
```
Ketik `yes` untuk konfirmasi penghapusan.

**⚠️ PERINGATAN**: Perintah ini akan menghapus SEMUA resource yang dibuat oleh Terraform!

---

## English

### Project Description
This project uses Terraform to provision infrastructure on Google Cloud Platform (GCP) and Docker Compose to run a WordPress application with MySQL database. All Docker installation and application deployment processes are automated during the VM's first boot.

### Architecture
- **VPC**: Custom virtual network for security isolation
- **Subnet**: Public subnet for internet access
- **Firewall**: Security rules for port 22 (SSH) and 8080 (WordPress)
- **VM**: e2-micro instance with Ubuntu 22.04 LTS
- **Application**: WordPress + MySQL using Docker Compose

### Prerequisites
Before starting, make sure you have installed:

1. **Terraform** (version >= 1.0)
   ```bash
   # Download from https://www.terraform.io/downloads.html
   # Or use package manager
   ```

2. **Google Cloud SDK (gcloud CLI)**
   ```bash
   # Download from https://cloud.google.com/sdk/docs/install
   ```

3. **Git**
   ```bash
   # For cloning the repository
   ```

4. **SSH Key Pair**
   ```bash
   # Create SSH key if you don't have one
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ```

### Initial Configuration

#### 1. Setup Google Cloud
```bash
# Login to Google Cloud
gcloud auth login

# Set project ID (replace with your project ID)
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Setup Application Default Credentials
gcloud auth application-default login
```

#### 2. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/terraform-wordpress-gcp.git
cd terraform-wordpress-gcp
```

#### 3. Configure Terraform
```bash
cd terraform

# Copy configuration file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your favorite editor
nano terraform.tfvars
```

Fill the `terraform.tfvars` file with your information:
```hcl
project_id = "your-actual-project-id"
region     = "asia-southeast2"
zone       = "asia-southeast2-a"

ssh_user             = "ubuntu"
ssh_public_key_path  = "~/.ssh/id_rsa.pub"

mysql_root_password = "secure-root-password"
mysql_database      = "wordpress"
mysql_user          = "wpuser"
mysql_password      = "secure-wp-password"
```

### Deployment Steps

#### 1. Initialize Terraform
```bash
cd terraform
terraform init
```

#### 2. Validate Configuration
```bash
terraform validate
terraform plan
```

#### 3. Deploy Infrastructure
```bash
terraform apply
```
Type `yes` when prompted for confirmation.

#### 4. Wait for Completion
Deployment will take about 5-10 minutes. Terraform will:
- Create VPC and subnet
- Create firewall rules
- Create VM with Ubuntu 22.04
- Automatically install Docker and Docker Compose
- Run WordPress and MySQL

### Verify Deployment

#### 1. Check Terraform Output
```bash
terraform output
```
You will see information like:
- VM IP address
- WordPress URL
- SSH command

#### 2. Access WordPress
Open your browser and visit:
```
http://VM_EXTERNAL_IP:8080
```

#### 3. SSH to VM (Optional)
```bash
ssh ubuntu@VM_EXTERNAL_IP
```

Check container status:
```bash
sudo docker ps
sudo docker-compose -f /home/wordpress-app/docker-compose.yml logs
```

### Troubleshooting

#### If WordPress is not accessible:
1. Wait a few minutes (startup script is still running)
2. Check startup script logs:
   ```bash
   ssh ubuntu@VM_EXTERNAL_IP
   sudo tail -f /var/log/startup-script.log
   ```

#### If there's an error during terraform apply:
1. Make sure project ID is correct
2. Make sure APIs are enabled
3. Make sure credentials are set up correctly

### Cleanup (Delete All Resources)
```bash
cd terraform
terraform destroy
```
Type `yes` to confirm deletion.

**⚠️ WARNING**: This command will delete ALL resources created by Terraform!

---

## File Structure
```
terraform-wordpress-gcp/
├── terraform/
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output definitions
│   └── terraform.tfvars.example # Example configuration file
├── app/
│   ├── docker-compose.yml      # Docker Compose configuration
│   └── .env.example            # Environment variables example
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

## Security Notes
- Change default passwords in production
- Use strong passwords for database
- Consider using Google Secret Manager for sensitive data
- Regularly update Docker images
- Monitor access logs

## Cost Estimation
- e2-micro instance: Free tier eligible (if within limits)
- Network egress: Minimal cost for basic usage
- Storage: ~$0.04/GB/month for standard persistent disk

## Support
If you encounter any issues, please check:
1. GCP quotas and limits
2. Billing account status
3. API enablement status
4. Network connectivity

---

**Made with ❤️ for Technical Assessment**