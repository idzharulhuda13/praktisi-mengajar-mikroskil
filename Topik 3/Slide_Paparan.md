# Topik 3: Non-Relational Database (MongoDB)
## Studi Kasus Implementasi NoSQL di Industri

[Link Slide Paparan](https://docs.google.com/presentation/d/1BdZ8wsKoLm6EbwrLj4du6OeEpvIhQwmHVprLexsqeLM/edit?slide=id.p1#slide=id.p1)
---

## 1. Kenapa NoSQL (MongoDB)?
Di industri modern, data seringkali tidak "rapi".
- **Schema-less:** Kita bisa simpan data tanpa harus mendefinisikan kolom dulu.
- **Horizontal Scaling:** Lebih mudah menambah kapasitas database dengan menambah mesin/server (Sharding).
- **Format JSON/BSON:** Sangat ramah untuk developer Javascript/Mobile Apps.

---

## 2. NoSQL Gotchas (Cerita dari Lapangan)

### 2.1 BSON Document Limit (16MB)
- **Masalah:** Anda simpan semua komentar user di dalam satu dokumen postingan. Tiba-tiba postingan viral, komentarnya jutaan.
- **Akibat:** Ukuran dokumen melebihi 16MB, database error, aplikasi crash.
- **Solusi:** Jangan gunakan "Infinite Nesting". Gunakan referensi (seperti Foreign Key ala SQL) jika data diprediksi membesar terus menerus.

### 2.2 Unbound Array
**Kasus:** Anda menyimpan histori chat dalam satu array di satu dokumen. 
- **Akibat:** Query pencarian jadi lambat karena MongoDB harus nge-load semua chat baru bisa difilter.

---

## 3. Overview Live Project: REY JSON Extraction

### 3.1 Project 3: Subscription Snapshot
- **Tantangan:** Satu user bisa punya banyak plan (Array of Objects).
- **Tujuan Bisnis:** Kita ingin mem-flatten (meratakan) data ini agar bisa di-join ke tabel SQL di Data Warehouse.
- **Teknik:** Kita akan menggunakan `$unwind`.

### 3.2 Project 4: Plans & Benefits
- **Tantangan:** Struktur benefit sangat dalam dan kompleks. Ada data benefit yang "sampah" (times = 0).
- **Tujuan Bisnis:** Membersihkan data benefit aktif saja untuk perhitungan limit asuransi.

---

## 4. Aggregation Pipeline (The Secret Sauce)
Di SQL kita pakai `GROUP BY` dan `HAVING`. Di MongoDB kita pakai **Pipeline**:
1. `$match`: Filter data (ala `WHERE`).
2. `$unwind`: Memecah array menjadi baris terpisah.
3. `$group`: Melakukan agregasi (ala `GROUP BY`).
4. `$project`: Memilih field yang mau tampil (ala `SELECT`).

---

## 5. AI dalam MongoDB
Menulis Aggregation Pipeline sering membuat kepala pusing.
- **Prompt:** "Buat aggregation pipeline MongoDB untuk mengambil plan_code dan menghitung total benefit per plan dari koleksi benefit_snapshot."
- **AI Tool:** MongoDB punya fitur **Compass Aggregation Builder** yang bisa dibantu AI untuk menyusun pipeline secara visual.

---

## Ayo Masuk ke Live Code!
Kita akan mempraktikkan:
1. **CRUD** dasar di MongoDB.
2. **Flattening Array** dengan `$unwind`.
3. **Filtering data** dengan `$match`.
