# Praktisi Mengajar: Basis Data 🚀
## AI-Augmented Database Learning | REY x Universitas Mikroskil Collaboration

![Collaboration](https://img.shields.io/badge/Collaboration-REY%20x%20Mikroskil-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Live%20Project-success?style=for-the-badge)
![Tech](https://img.shields.io/badge/Tech-MySQL%20%7C%20MongoDB-orange?style=for-the-badge)

Selamat datang di repositori mata kuliah **Praktisi Mengajar: Basis Data**. Program ini merupakan kolaborasi antara **REY** dan **Universitas Mikroskil** untuk membekali mahasiswa dengan keahlian database modern yang relevan dengan industri.

---

## 📖 Ringkasan Kurikulum

Mata kuliah ini dirancang untuk menjembatani teori akademis dengan kebutuhan industri melalui pendekatan **AI-Augmented Learning**, di mana mahasiswa diajak menggunakan AI (ChatGPT, Claude, LLM) sebagai asisten dalam perancangan dan optimasi database.

### Struktur Pembelajaran
| Topik | Judul | Deskripsi |
| :--- | :--- | :--- |
| **Topic 1** | [Relational vs NoSQL](Topik%201/Slide_Paparan.md) | Roadmap karir data (DE/DA/DS/AE) dan strategi pemilihan database. |
| **Topic 2** | [RDBMS (MySQL)](Topik%202/Slide_Paparan.md) | Dasar-dasar SQL, Stored Procedures, View, dan Trigger untuk otomasi bisnis. |
| **Topic 3** | [NoSQL (MongoDB)](Topik%203/Slide_Paparan.md) | Penanganan data semi-terstruktur menggunakan Aggregation Pipeline. |
| **Project** | [Tugas Proyek](Tugas%20Proyek/Panduan_Proyek.md) | Simulasi peran *Analytics Engineer* di REY melalui real-world case studies. |

---

## 🛠️ Persiapan Lingkungan (Environment Setup)

Untuk mempermudah proses belajar, semua database dijalankan menggunakan **Docker**. Pastikan Anda sudah menginstal [Docker Desktop](https://www.docker.com/products/docker-desktop/).

### Menjalankan Database
1. Buka terminal pada folder `Environment`.
2. Jalankan perintah:
   ```bash
   docker-compose up -d
   ```

### Informasi Koneksi
- **MySQL:** `localhost:3306` (User: `root`, Pass: `password`)
- **MongoDB:** `localhost:27017` (User: `admin`, Pass: `password`)

---

## 🎯 Proyek Akhir: Analytics Engineer Simulation

Mahasiswa ditantang untuk menyelesaikan 4 mini-project yang merepresentasikan tantangan nyata di REY:
1. **Membership Cohort Analysis (MySQL)**: Menganalisa retensi pengguna.
2. **User Engagement Modeling (MySQL)**: Membuat sistem skor kesehatan otomatis.
3. **JSON Subscription Snapshot (MongoDB)**: Ekstraksi data asuransi kompleks.
4. **JSON Plan & Benefits (MongoDB)**: Transformasi data benefit yang dinamis.

---

## 📂 Struktur Repositori

```text
.
├── Environment/              # Konfigurasi Docker (MySQL & MongoDB)
├── Topik 1/                  # Materi Teori & Roadmap Karir
├── Topik 2/                  # Praktik MySQL (Script & Slides)
├── Topik 3/                  # Praktik MongoDB (Script & Slides)
├── Tugas Proyek/             # Panduan Proyek & Rubrik Penilaian
```

---

## 🔓 Akses File Terproteksi

Beberapa materi live project disimpan dalam file arsip terproteksi: `Live_Project_REY_x_Mikroskil.zip`. Password dapat diperoleh dengan menanyakan langsung kepada author atau akan diinformasikan saat sesi di kelas.

---

&copy; 2026 REY x Universitas Mikroskil. All rights reserved.
