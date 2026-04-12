# Topik 1: Relational vs Non-Relational Database
## Studi Kasus Penerapan di Industri & Roadmap Karir Data

[Link Slide Paparan](https://docs.google.com/presentation/d/1WDAt9qJB4shQ-1zKi_XX9aiKwCutpjvo4u0Oa4ILcAo/edit?slide=id.p1#slide=id.p1)

---

## 1. Intermezzo: Siapa yang Mengelola Data?
Di industri modern, "orang data" bukan cuma satu jenis. Berikut perbedaannya:

### 1.1 Data Engineer (The Architect)
- **Fokus:** Membangun "jalan raya" data (Pipeline).
- **Tool:** SQL, Python, Spark, Airflow, Kafka.
- **Tugas:** Memastikan data berpindah dari sumber ke database dengan aman, cepat, dan terstruktur.

### 1.2 Data Analyst (The Storyteller)
- **Fokus:** Mengubah data jadi keputusan bisnis.
- **Tool:** SQL, Tableau, PowerBI, Excel.
- **Tugas:** Menjawab pertanyaan: "Berapa churn rate kita bulan lalu?" atau "Kenapa penjualan turun?".

### 1.3 Data Scientist (The Predictor)
- **Fokus:** Membuat model prediksi.
- **Tool:** Python/R, Machine Learning, Statistics.
- **Tugas:** Membangun sistem rekomendasi atau memprediksi kapan user akan berhenti berlangganan.

### 1.4 Analytics Engineer (The Bridge)
- **Fokus:** Menyediakan data yang "siap pakai" untuk analyst/scientist.
- **Tool:** dbt (data build tool), SQL, Snowflake/BigQuery.
- **Tugas:** Membersihkan data mentah dari Data Engineer menjadi tabel yang bersih dan terdokumentasi dengan baik.

---

## 2. Paradigma Database: Relational vs Non-Relational

### 2.1 Relational Database (RDBMS)
- **Konsep:** Tabel, Kolom, Baris, Hubungan (Foreign Key).
- **Contoh:** MySQL, PostgreSQL, SQL Server.
- **Kelebihan:** ACID Compliance (Transaksi aman), Integritas data tinggi.
- **Kapan Digunakan?** Sistem Keuangan, Transaksi Order, User Profile.

### 2.2 Non-Relational Database (NoSQL)
- **Konsep:** Dokumen (JSON), Key-Value, Graph, Wide Column.
- **Contoh:** MongoDB, Redis, Neo4j, Cassandra.
- **Kelebihan:** Fleksibel, Skalabilitas Horizontal tinggi, Cepat untuk data semi-terstruktur.
- **Kapan Digunakan?** Aktivitas Log, Real-time Chat, Katalog Produk yang dinamis.

---

## 3. Cerita dari Lapangan (Industry Experience)

### 3.1 "Mimpi Buruk" Migrasi Skema di RDBMS
**Kasus:** Aplikasi sudah punya 10 juta user. Tiba-tiba ada kebutuhan tambah 1 kolom di tabel `users`.
- **Masalah:** Saat menjalankan `ALTER TABLE`, database me-lock tabel tersebut. Aplikasi tidak bisa login selama 1 jam.
- **Solusi Industri:** Menggunakan tool migrasi online (pt-online-schema-change) atau beralih ke strategi "Expand-Contract".

### 3.2 MongoDB "Data Soup" (Data Berantakan)
**Kasus:** Karena MongoDB tidak memaksa skema, developer bebas memasukkan field apa saja.
- **Masalah:** Setelah 1 tahun, ada 10 variasi nama field untuk "tanggal lahir" (`dob`, `date_of_birth`, `birthdate`, `tgl_lahir`).
- **Solusi Industri:** Tetap harus ada "Schema Validation" di level aplikasi atau menggunakan fitur validator di MongoDB.

---

## 4. Hybrid Database Architecture (Real Case: REY)
Di startup seperti **REY**, kita tidak menggunakan MongoDB. Arsitektur sebenarnya adalah:
- **Operational Database (PostgreSQL):** Menyimpan data transaksi & user. Data "Non-Relational" tetap disimpan di sini menggunakan tipe data **JSONB**.
- **Data Pipeline (Airflow):** Mereplikasi data dari Postgres ke Data Warehouse.
- **Data Warehouse (BigQuery):** Tempat semua data (Relational & JSON) berkumpul dalam skala masif.
- **Transformation (dbt):** Di sinilah "sihir" pembersihan data terjadi. Kita merubah data JSON yang berantakan menjadi tabel yang rapi menggunakan SQL di BigQuery.

---

## 5. AI-Augmented Database Learning
Dulu, kita harus menghafal sintaks SQL yang rumit. Sekarang, AI membantu kita:
1. **Perancangan Skema:** "Buatlah skema database untuk aplikasi kesehatan yang punya fitur asuransi dan log lari."
2. **Query Optimization:** "Bagaimana cara mempercepat query join 5 tabel ini?"
3. **Drafting Code:** "Buatlah Stored Procedure MySQL untuk menghitung skor kesehatan."

**Tapi Ingat:** AI bisa salah (Hallucination). Tanpa dasar pemahaman yang kuat, Anda tidak akan tahu jika AI memberikan skema yang tidak efisien atau tidak aman.

---

## Diskusi
1. Apakah menurut kalian media sosial (Instagram/TikTok) lebih cocok pakai RDBMS atau NoSQL? Mengapa?
2. Peran manakah (DE/DA/DS/AE) yang paling menarik buat kalian?
