# WordPress Deployment on Google Cloud Platform

---

### Objective
Proyek ini menggunakan Terraform untuk membuat infrastruktur di Google Cloud Platform (GCP) dan Docker Compose untuk menjalankan aplikasi WordPress dengan database MySQL. Semua proses instalasi Docker dan deployment aplikasi dilakukan secara otomatis saat VM pertama kali dinyalakan.

### Architecture
- **VPC**: Jaringan virtual khusus untuk isolasi keamanan
- **Subnet**: Subnet publik untuk akses internet
- **Firewall**: Aturan keamanan untuk port 22 (SSH) dan 8080 (WordPress)
- **VM**: Instance e2-micro dengan Ubuntu 22.04 LTS
- **Aplikasi**: WordPress + MySQL menggunakan Docker Compose

### Prerequisites
Sebelum memulai, pastikan Anda sudah menginstal:

1. **Terraform** (versi >= 1.0)

   Download dari https://www.terraform.io/downloads.html.
   Atau gunakan package manager.
   

2. **Google Cloud SDK (gcloud CLI)**

   Download dari https://cloud.google.com/sdk/docs/install.
   

3. **Git**

   Untuk clone repository.
   

### Konfigurasi Awal

#### 1. Setup Google Cloud 

- **Menggunakan Cloud Shell**

   Masuk ke https://console.cloud.google.com kemudian buka cloud shell (Terletak di pojok kanan atas dengan logo terminal).

- **Atau menggunakan Cloud SDK**

   Buka Cloud SDK Terminal yang sudah diinstall.

```bash
# Login ke Google Cloud
gcloud auth login

# Set project ID (ganti dengan project ID Anda)
gcloud config set project YOUR_PROJECT_ID

# Enable APIs yang diperlukan
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

```

#### 2. Clone Repository
```bash
git clone https://github.com/ndchsn/terraform-wordpress-gcp.git
cd terraform-wordpress-gcp
```

#### 3. Konfigurasi Terraform
```bash
cd terraform

# Copy file konfigurasi
cp terraform.tfvars.example terraform.tfvars

# Edit file terraform.tfvars dengan nano atau vim
nano terraform.tfvars
```

Isi file `terraform.tfvars` dengan informasi Anda:
```hcl
project_id = "your-project-id"
region     = "asia-southeast2"
zone       = "asia-southeast2-a"

mysql_root_password = "password-root-yang-aman"
mysql_database      = "wordpress"
mysql_user          = "wpuser"
mysql_password      = "password-wp-yang-aman"
```

### Deployment Steps

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

Instalasi akan memakan waktu sekitar 10-20 menit tambahan setelah deployment VM selesai. Startup Script akan:
- Menginstal Docker dan Docker Compose secara otomatis
- Menjalankan WordPress dan MySQL

### Verification:

### 1. Cek Output Terraform
```bash
terraform output
```
Anda akan melihat informasi seperti:
- IP address VM
- URL WordPress
- Command SSH

### 2. Akses WordPress
Buka browser dan kunjungi:
```
http://VM_EXTERNAL_IP:8080
```

### 3. SSH ke VM 

- **Lewat Console Cloud Google**

   Masuk ke https://console.cloud.google.com/compute/instances atau di halaman navigasi sebelah kiri console GCP, masuk ke Compute Engine > VM Instances, Klik SSH di VM yang sudah dibuat.

- **SSH lewat cloud shell**

```bash
terraform output ssh_command
gcloud compute ssh --project <PROJECT_ID> --zone <ZONE> wordpress-vm
```

- **SSH lewat terminal Cloud SDK**

```bash
terraform output ssh_command
gcloud compute ssh --project <PROJECT_ID> --zone <ZONE> wordpress-vm
```

Cek status container:
```bash
sudo docker ps
sudo docker-compose -f /home/wordpress-app/docker-compose.yml logs
```

### 4. Verifikasi Volume Service Database

- **Cek Konfigurasi Volume di Docker**
```bash
cd /home/wordpress-app
sudo docker inspect wordpress_db #Verifikasi volume db
```

- **Uji Persistent Data**
```bash
sudo docker-compose down #Hentikan dan Hapus Kontainer
sudo docker-compose up -d #Jalankan kembali kontainer
```

### 5. Verifikasi Volume Service Wordpress

```bash
sudo docker logs wordpress_app #Verifikasi dependensi wordpress terhadap db
sudo docker inspect wordpress_app #Verifikasi volume wordpress
```


### Troubleshooting

#### Jika WordPress tidak bisa diakses:
1. Tunggu beberapa menit (startup script masih berjalan)
2. Cek log startup script:
   ```bash
   gcloud compute ssh --project <PROJECT_ID> --zone <ZONE> wordpress-vm
   sudo tail -f /var/log/startup-script.log
   ```

#### Jika ada error saat terraform apply:
1. Pastikan project ID benar
2. Pastikan APIs sudah diaktifkan
3. Pastikan credentials sudah di-setup dengan benar

### Cleanup (Hapus Semua Resource):
```bash
cd terraform
terraform destroy
```
Ketik `yes` untuk konfirmasi penghapusan.

**⚠️ PERINGATAN**: Perintah ini akan menghapus SEMUA resource yang dibuat oleh Terraform!

-----

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
└── README.md                   # Guidance
```

## Security Notes
- Ganti password default di environment Production
- Gunakan password yang kuat untuk database
- Pertimbangkan untuk menggunakan Google Secret Manager untuk data sensitif
- Update Docker Image secara berkala
- Monitoring log akses

## Cost Estimation
- e2-micro instance: Free tier eligible
- Network egress: Minimal cost for basic usage
- Storage: ~$0.04/GB/month for standard persistent disk

## Support
Jika menemukan masalah yang lain, bisa cek:
1. GCP quotas and limits
2. Billing account status
3. API enablement status
4. Network connectivity

---
