# Topik 2: Advance Relational Database (MySQL)
## Studi Kasus Penerapan Objek Basis Data di Industri

[Link Slide Paparan](https://docs.google.com/presentation/d/1STCyJU0sovXKT6pjeaEVNmj6baJhu7JXDYOmk7edy8A/edit?slide=id.p1#slide=id.p1)
---

## 1. Kenapa "Query Biasa" Tidak Cukup di Industri?
Di bangku kuliah, kita belajar `SELECT * FROM table`. Di industri:
- Kita butuh **Logic di Database** (Stored Proc/Function).
- Kita butuh **Automatisasi** (Trigger).
- Kita butuh **Abstraksi** (View).

---

## 2. Advanced Objects: Weapon of Choice

### 2.1 Database View
- **Konsep:** Tabel virtual hasil query.
- **Kasus Riil:** Menyembunyikan kolom sensitif (Gaji, Password) atau menyederhanakan join 10 tabel yang rumit.
- **Gotcha:** View di MySQL bisa jadi lambat kalau query-nya mengandung subquery berat. Jangan asal tumpuk View di atas View.

### 2.2 Stored Procedure & Function
- **Konsep:** Sekumpulan perintah SQL yang disimpan dan bisa dipanggil.
- **Kasus Riil:** Proses "Checkout" yang melibatkan: 
  1. Cek stok, 
  2. Kurangi saldo, 
  3. Buat invoice.
  Semua dilakukan dalam 1 kali panggil (mengurangi *network round-trip*).

### 2.3 Trigger
- **Konsep:** Perintah yang otomatis jalan saat ada `INSERT/UPDATE/DELETE`.
- **Kasus Riil:** Update otomatis kolom `total_stok` di tabel `products` tiap ada penjualan di tabel `order_details`.
- **Gotcha (PENTING):** Trigger sulit di-*debug* dan bisa membuat database "misterius". Industri besar mulai menghindari Trigger dan memilih logika di level aplikasi (Service Layer).

---

## 3. Overview Live Project: REY Case Study

### 3.1 Project 1: Membership Cohort Analysis
- **Masalah Bisnis:** Kapan user kita berhenti berlangganan? Apakah user yang daftar di Januari lebih setia dibanding Pebruari?
- **Logic Database:** Kita butuh menghitung selisih bulan antara `start_date` dan waktu sekarang untuk setiap user.

### 3.2 Project 2: Engagement Modeling & Scoring
- **Masalah Bisnis:** Kita ingin memberi reward kepada user yang aktif. Tapi, bagaimana menentukan siapa yang "paling aktif" secara adil?
- **Sistem Scoring (Industry Standard):**
  - Tidak hanya pakai poin manual (misal: 1 poin per notif).
  - Menggunakan **Z-Score**: Menghitung seberapa jauh aktivitas user dibanding rata-rata populasi.
  - **Normalisasi**: Mengubah angka statistik (Z-score) menjadi nilai 0-100 agar mudah dibaca oleh tim bisnis.
- **Tujuan:** Membuat tabel dashboard `user_engagement_scores`.

---

## 4. AI dalam Pengembangan MySQL
AI sangat lihai membuatkan skrip Stored Procedure yang panjang:
1. **Prompt:** "Buat Stored Procedure untuk menghitung skor engagement dari 3 tabel berbeda dengan logika bobot tertentu."
2. **Review:** Anda tetap harus mengecek apakah skrip tersebut menggunakan `TRANSACATION` agar data tidak korup jika error di tengah jalan.

---

## 5. Live Demo 2: AI-Augmented Analysis (Gemini + MySQL)
Tidak hanya membuat query manual, kita bisa menggunakan LLM untuk mempercepat analisis:

### Pipeline:
1. **Berikan Schema** -> Gemini tahu tabel dan kolom yang tersedia
2. **Tanya dalam Bahasa Manusia** -> "Berapa user aktif per cohort bulan?"
3. **Gemini Generate SQL** -> LLM translate pertanyaan ke query
4. **Execute & Dapat Hasil** -> Query dijalankan di MySQL
5. **Gemini Analyze** -> LLM menjelaskan insight dalam bahasa Indonesia

### Kenapa Ini Penting?
- Analytics Engineer modern tidak hanya menulis SQL — mereka **memformulasikan pertanyaan bisnis yang tepat**
- AI membantu mempercepat eksplorasi, tapi **human review tetap wajib**
- Bukan menggantikan skill SQL — tapi **mengamplifikasi** kemampuan analisis

---

## Ayo Masuk ke Live Code!
Kita akan mempraktikkan cara membuat:
1. **View** untuk memantau Cohort.
2. **Logic Statistik** (Z-Score & Normalization) untuk Ranking User.
3. **Trigger** untuk automasi data.
4. **Bonus Demo**: Gemini API + MySQL — AI generate SQL & analisis otomatis.
