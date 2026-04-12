# Environment Setup - Praktisi Mengajar Basis Data

Selamat datang di modul persiapan lingkungan kerja (Environment Setup). Untuk memastikan semua mahasiswa memiliki konfigurasi yang sama tanpa kendala instalasi manual, kita akan menggunakan **Docker**.

## Prasyarat
- Sudah menginstal **Docker Desktop** (untuk Windows/Mac) atau Docker Engine (untuk Linux).

## Cara Menjalankan
1. Buka Terminal atau Command Prompt di folder `Environment`.
2. Jalankan perintah berikut:
   ```bash
   docker-compose up -d
   ```
3. Docker akan mengunduh image MySQL dan MongoDB, lalu menjalankannya di latar belakang.

## Informasi Koneksi

### 1. MySQL
- **Host:** `localhost`
- **Port:** `3306`
- **Database:** `db_rey_mikroskil`
- **User:** `root`
- **Password:** `password`

### 2. MongoDB
- **URI:** `mongodb://admin:password@localhost:27017/db_rey_mikroskil?authSource=admin`
- **Host:** `localhost`
- **Port:** `27017`
- **User:** `admin`
- **Password:** `password`

## Menghentikan Layanan
Jika sudah selesai, Anda bisa menghentikan container dengan perintah:
```bash
docker-compose down
```
_Catatan: Data akan tetap tersimpan di folder `mysql-data` dan `mongo-data` di dalam direktori Environment ini._
