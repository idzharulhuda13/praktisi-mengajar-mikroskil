# WALKTHROUGH LENGKAP: Topik 2 — Dari Demo 1 ke Demo 2
## Praktisi Mengajar: Basis Data — REY x Mikroskil

> Dokumen ini adalah panduan langkah-demi-langkah untuk mahasiswa. Ikuti dari atas ke bawah. Setiap langkah punya perintah yang bisa langsung di-copy-paste dan penjelasan "kenapa kita melakukan ini".

---

## BAGIAN 0: PERSIAPAN (Sebelum Kelas Dimulai)

### 0.1 Install Semua yang Dibutuhkan

Pastikan 4 hal ini sudah terinstall di laptop kamu:

**1. Python 3.10+**
```bash
python3 --version
```
Jika belum ada, download dari https://www.python.org/downloads/

**2. Docker Desktop**
```bash
docker --version
docker info
```
Jika belum ada, download dari https://www.docker.com/products/docker-desktop/
> Pastikan Docker Desktop sudah running (ada icon paus di system tray/menu bar).

**3. Git**
```bash
git --version
```

**4. uv (Python package manager)**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```
> Windows (PowerShell): `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`

**5. Gemini API Key (GRATIS)**
- Buka https://aistudio.google.com/apikey
- Login dengan Google account
- Klik "Create API Key"
- Copy key-nya — kita akan simpan di file `.env` nanti

---

### 0.2 Clone Repository

```bash
git clone <repo-url>
cd praktisi-mengajar-mikroskil/Topik\ 2
```

Setelah masuk ke folder `Topik 2`, pastikan file-file ini ada:
```bash
ls -la
```

Yang harus terlihat:
- `Makefile` — command center untuk semua operasi
- `docker-compose.yml` — konfigurasi MySQL container
- `pyproject.toml` — daftar Python dependencies
- `init_mysql.sql` — schema database (tanpa data — data diload dari XLSX)
- `load_data.py` — loader yang baca XLSX dan insert ke MySQL
- `data/` — folder berisi XLSX dari REY (sudah disediakan dosen, gitignored)
- `gemini_mysql_demo.ipynb` — Jupyter Notebook untuk Demo 2
- `materi/Slide_Paparan.md` — materi presentasi
- `materi/Live_Code_MySQL.md` — script SQL untuk Demo 1

---

## BAGIAN 1: DEMO 1 — MySQL Advanced Features
### (View, Stored Procedure, Trigger)

### 1.1 Start MySQL Database

```bash
make up
```

Apa yang terjadi:
- Docker akan download image MySQL 8.0 (jika belum ada)
- Buat container bernama `mikroskil-mysql-topik2`
- Jalankan `init_mysql.sql` otomatis saat pertama kali start
- Database `db_rey_mikroskil` dibuat dengan 4 tabel + 1 view (masih kosong — belum ada data)

Verifikasi container running:
```bash
docker ps
```

Harusnya terlihat container `mikroskil-mysql-topik2` dengan status "Up".

---

### 1.1.5 Load Data dari XLSX

File XLSX dari REY sudah ada di folder `data/`. Sekarang load isinya ke MySQL:

```bash
make load-data
```

Apa yang terjadi:
- Script `load_data.py` baca 2 file XLSX di `data/`
- Transform kolom (misal `join_date` → `start_date`, derive `status` dari ada/tidaknya `termination_date`)
- TRUNCATE tabel lama lalu INSERT data baru
- Total 4 tabel terisi: `subscriptions` (~5.4k baris), `user_logins` (~258), `reyfit_logs` (~1k), `health_diaries` (~230)

Output yang diharapkan:
```
  subscriptions: 5431 rows
  user_logins:   258 rows
  reyfit_logs:   1058 rows
  health_diaries:230 rows
Done.
```

> **Kenapa load terpisah dari `init_mysql.sql`?** Schema (struktur tabel) jarang berubah, tapi data bisa di-refresh kapan saja tanpa drop database. Pattern ini umum di production data pipeline: schema versioned di code, data di-load dari sumber eksternal.

---

### 1.2 Masuk ke MySQL

Buka MySQL command line via Docker:

```bash
docker exec -it mikroskil-mysql-topik2 mysql -uroot -ppassword db_rey_mikroskil
```

Sekarang kamu sudah di dalam MySQL prompt (`mysql>`).

---

### 1.3 Eksplorasi Data yang Sudah Ada

Kita punya database dengan tabel-tabel berikut. Cek dulu isinya:

```sql
SHOW TABLES;
```

Output yang diharapkan:
```
+-----------------------------+
| Tables_in_db_rey_mikroskil  |
+-----------------------------+
| health_diaries              |
| reyfit_logs                 |
| subscriptions               |
| user_engagement_scores      |
| user_logins                 |
| users                       |
+-----------------------------+
```

Lihat data di setiap tabel. Karena dataset real-nya besar, pakai `LIMIT 5`:

```sql
-- Tabel subscriptions (data langganan user dari REY)
SELECT * FROM subscriptions LIMIT 5;
SELECT COUNT(*) FROM subscriptions;
```

Output (contoh — angka aktual tergantung data XLSX):
```
+-----------------+---------+------------+----------+----------+
| subscription_id | user_id | start_date | end_date | status   |
+-----------------+---------+------------+----------+----------+
|               1 |   32095 | 2024-01-02 | NULL     | active   |
|               2 |   32142 | 2024-01-03 | NULL     | active   |
|               3 |   32071 | 2024-01-03 | NULL     | active   |
|               4 |   32119 | 2024-01-03 | NULL     | active   |
|               5 |   31400 | 2024-01-04 | NULL     | active   |
+-----------------+---------+------------+----------+----------+

+----------+
| COUNT(*) |
+----------+
|     5431 |
+----------+
```

```sql
-- View users (derived dari tabel aktivitas — user_id, first_activity, last_activity)
SELECT * FROM users LIMIT 5;
```

```sql
-- Tabel user_logins (record last login per user/platform)
SELECT * FROM user_logins LIMIT 5;
```

Output:
```
+----------+---------+----------+----------------------------+
| login_id | user_id | platform | last_login_at              |
+----------+---------+----------+----------------------------+
|        1 |      39 | android  | 2025-05-24 04:30:25.187000 |
|        2 |      67 | ios      | 2025-04-08 05:10:23.950000 |
|        3 |      76 | ios      | 2025-02-08 05:04:13.896000 |
+----------+---------+----------+----------------------------+
```

```sql
-- Tabel reyfit_logs (agregat bulanan: langkah & hidrasi)
SELECT * FROM reyfit_logs LIMIT 5;
```

Output:
```
+--------+---------+--------------+-------------+--------------------+
| log_id | user_id | active_month | step_counts | total_hydration_ml |
+--------+---------+--------------+-------------+--------------------+
|      1 |      67 | 2024-01-01   | NULL        |               3500 |
|      2 |      67 | 2024-02-01   | NULL        |               NULL |
|      3 |      67 | 2024-03-01   | NULL        |               NULL |
+--------+---------+--------------+-------------+--------------------+
```

```sql
-- Tabel health_diaries (jumlah catatan diary per bulan per user)
SELECT * FROM health_diaries LIMIT 5;
```

Output:
```
+----------+---------+--------------+---------------+
| diary_id | user_id | active_month | count_diaries |
+----------+---------+--------------+---------------+
|        1 |      39 | 2024-01-01   |             8 |
|        2 |      39 | 2024-06-01   |             1 |
|        3 |      76 | 2024-01-01   |             2 |
+----------+---------+--------------+---------------+
```

```sql
-- Tabel user_engagement_scores (masih kosong — nanti kita isi)
SELECT * FROM user_engagement_scores;
```

> **Penjelasan**: Kita punya 4 tabel data + 1 view + 1 tabel hasil. `subscriptions` menyimpan data langganan (~5.4k baris), dan 3 tabel (`user_logins`, `reyfit_logs`, `health_diaries`) menyimpan aktivitas user. `users` adalah **VIEW** turunan — di-generate dari UNION semua tabel aktivitas, jadi tidak menyimpan PII (nama/email). Tabel `user_engagement_scores` masih kosong — nanti akan kita isi lewat Stored Procedure.
>
> **Catatan kolom**: `step_counts` di `reyfit_logs` sering NULL karena data tracking awal — kita anggap user tetap aktif jika ada baris untuk bulan itu (proxy: jumlah bulan dengan record). Sama untuk `total_hydration_ml`.

---

### 1.4 Membuat VIEW — Cohort Analysis

**Apa itu View?**
View itu seperti "query yang disimpan" atau "tabel virtual". Dia tidak menyimpan data sendiri, tapi每次 di-query, dia menjalankan query di baliknya.

**Kenapa pakai View?**
- Menyederhanakan query rumit jadi satu nama
- Bisa dipakai berulang kali tanpa tulis ulang
- Bisa dipakai untuk menyembunyikan kolom sensitif

**Kasus: Cohort Analysis**
Kita ingin tahu: user yang daftar di bulan Januari, berapa lama mereka bertahan? Februari? Maret?

```sql
CREATE OR REPLACE VIEW view_user_cohort AS
SELECT 
    user_id, 
    start_date,
    end_date,
    DATE_FORMAT(start_date, '%Y-%m-01') AS cohort_month,
    TIMESTAMPDIFF(MONTH, start_date, IFNULL(end_date, MAX(start_date) OVER ())) AS sub_age_months
FROM subscriptions;
```

Penjelasan tiap kolom:
- `cohort_month`: Bulan pertama user berlangganan (dibulatkan ke tanggal 1)
- `sub_age_months`: Berapa bulan user sudah berlangganan (dari start_date sampai end_date, atau sampai hari ini jika masih active)
- `IFNULL(end_date, CURRENT_DATE)`: Jika end_date NULL (masih active), pakai tanggal hari ini

Sekarang query view-nya (limit karena 5k+ baris):

```sql
SELECT * FROM view_user_cohort LIMIT 5;
```

Output (contoh):
```
+---------+------------+----------+--------------+----------------+
| user_id | start_date | end_date | cohort_month | sub_age_months |
+---------+------------+----------+--------------+----------------+
|   32095 | 2024-01-02 | NULL     | 2024-01-01   |             16 |
|   32142 | 2024-01-03 | NULL     | 2024-01-01   |             16 |
|   32071 | 2024-01-03 | NULL     | 2024-01-01   |             16 |
|   32119 | 2024-01-03 | NULL     | 2024-01-01   |             16 |
|   31400 | 2024-01-04 | NULL     | 2024-01-01   |             16 |
+---------+------------+----------+--------------+----------------+
```

Sekarang agregasi — berapa user per cohort bulan:

```sql
SELECT 
    cohort_month,
    COUNT(user_id) AS total_users
FROM view_user_cohort
GROUP BY cohort_month
ORDER BY cohort_month;
```

Output (contoh — angka aktual tergantung data XLSX):
```
+--------------+-------------+
| cohort_month | total_users |
+--------------+-------------+
| 2024-01-01   |          78 |
| 2024-02-01   |          80 |
| 2024-03-01   |          10 |
| 2024-04-01   |         548 |
| 2024-05-01   |         237 |
| 2024-06-01   |         124 |
| 2024-07-01   |         895 |
| 2024-08-01   |          52 |
+--------------+-------------+
... (18 cohorts total)
```

> **Insight**: Cohort sangat tidak merata — Juli 2024 punya 895 user baru, sementara Maret cuma 10. Spike di April & Juli hint adanya campaign akuisisi. Pola seperti ini exactly yang tim growth ingin tahu — cohort analysis bikin mereka bisa attribute spike ke campaign mana.

---

### 1.5 Menghitung Z-Score — Statistik Engagement

**Masalah**: Bagaimana cara menentukan siapa user "paling aktif" secara adil? Tidak bisa cuma hitung jumlah aktivitas — user yang sudah lama pasti punya lebih banyak aktivitas.

**Solusi: Z-Score**
Z-Score menjawab: "Seberapa jauh aktivitas user ini dari rata-rata semua user?"

Formula: `z = (nilai_user - rata_rata) / standar_deviasi`

- z > 0 = di atas rata-rata
- z < 0 = di bawah rata-rata
- z = 0 = tepat di rata-rata

**Step A: Buat View untuk Agregasi Aktivitas Mentah**

```sql
CREATE OR REPLACE VIEW view_raw_activities AS
SELECT 
    u.user_id,
    (
        (SELECT COUNT(*) FROM user_logins l WHERE l.user_id = u.user_id) +
        (SELECT COUNT(*) FROM reyfit_logs r WHERE r.user_id = u.user_id) +
        (SELECT COUNT(*) FROM health_diaries h WHERE h.user_id = u.user_id)
    ) AS raw_activity
FROM users u;
```

Penjelasan: Untuk setiap user, kita hitung total aktivitas dari 3 sumber:
1. Jumlah record login (`user_logins`) — proxy untuk seberapa sering user login
2. Jumlah bulan aktif di Reyfit (`reyfit_logs`) — proxy untuk konsistensi fitness
3. Jumlah bulan ada catatan diary (`health_diaries`)

Kenapa pakai `COUNT(*)` bukan SUM(step_counts)? Karena `step_counts` banyak yang NULL di data awal — kita tetap mau kasih kredit ke user yang aktif (punya record bulan itu) walaupun step-nya belum tercatat.

Cek hasilnya — tampilkan top 5 paling aktif:

```sql
SELECT * FROM view_raw_activities 
ORDER BY raw_activity DESC 
LIMIT 5;
```

Output (contoh):
```
+---------+--------------+
| user_id | raw_activity |
+---------+--------------+
|    1989 |           26 |
|   31301 |           23 |
|   28548 |           21 |
|    1427 |           19 |
|    1522 |           19 |
+---------+--------------+
```

**Step B: Hitung Z-Score dengan Window Functions**

```sql
SELECT 
    user_id,
    raw_activity,
    (raw_activity - AVG(raw_activity) OVER()) / NULLIF(STDDEV(raw_activity) OVER(), 0) as z_score
FROM view_raw_activities
ORDER BY z_score DESC
LIMIT 5;
```

Penjelasan:
- `AVG(raw_activity) OVER()`: Rata-rata semua user (tanpa GROUP BY — window function)
- `STDDEV(raw_activity) OVER()`: Standar deviasi semua user
- `NULLIF(..., 0)`: Mencegah division by zero jika semua user punya aktivitas sama

Output (contoh):
```
+---------+--------------+----------+
| user_id | raw_activity | z_score  |
+---------+--------------+----------+
|    1989 |           26 |  3.11    |
|   31301 |           23 |  2.65    |
|   28548 |           21 |  2.33    |
|    1427 |           19 |  2.02    |
|    1522 |           19 |  2.02    |
+---------+--------------+----------+
```

> **Insight**: Rata-rata `raw_activity` adalah ~6 dengan stddev ~6.4. User `1989` punya z-score 3.11 — artinya dia 3+ standar deviasi di atas rata-rata, super outlier. Ini kandidat utama untuk segment "Superstar".

---

### 1.6 Membuat STORED PROCEDURE — Refresh Ranking

**Apa itu Stored Procedure?**
Sekumpulan perintah SQL yang disimpan di database dan bisa dipanggil dengan satu perintah. Seperti "fungsi" di programming.

**Kenapa pakai Stored Procedure?**
- Satu panggilan = banyak operasi (kurangi network round-trip)
- Logic terpusat di database
- Bisa dipakai oleh aplikasi (backend) tanpa tulis ulang SQL

Buat Stored Procedure:

```sql
DELIMITER //

CREATE PROCEDURE sp_refresh_engagement_rankings()
BEGIN
    -- Hapus data lama
    TRUNCATE TABLE user_engagement_scores;

    -- Hitung dan simpan skor baru
    INSERT INTO user_engagement_scores (user_id, total_activity, z_score, normalized_score, segment)
    SELECT 
        user_id,
        raw_activity,
        z_score,
        -- Normalisasi ke skala 0-100
        CASE 
            WHEN max_z = min_z THEN 100 
            ELSE (z_score - min_z) / (max_z - min_z) * 100 
        END as normalized_score,
        -- Segmentasi berdasarkan z-score
        CASE 
            WHEN z_score > 1 THEN 'Superstar'
            WHEN z_score > 0 THEN 'Average'
            ELSE 'Passive'
        END as segment
    FROM (
        SELECT 
            user_id,
            raw_activity,
            z_score,
            MIN(z_score) OVER() as min_z,
            MAX(z_score) OVER() as max_z
        FROM (
            SELECT 
                user_id,
                raw_activity,
                (raw_activity - AVG(raw_activity) OVER()) / NULLIF(STDDEV(raw_activity) OVER(), 0) as z_score
            FROM view_raw_activities
        ) z_calc
    ) final_calc;
END //

DELIMITER ;
```

> **Penting**: `DELIMITER //` digunakan karena Stored Procedure punya banyak tanda `;` di dalamnya. Kita ganti delimiter sementara jadi `//` agar MySQL tidak menganggap `;` di tengah procedure sebagai akhir perintah.

**Jalankan Stored Procedure:**

```sql
CALL sp_refresh_engagement_rankings();
```

**Lihat hasilnya — top 5:**

```sql
SELECT * FROM user_engagement_scores ORDER BY normalized_score DESC LIMIT 5;
```

Output (contoh):
```
+---------+----------------+---------+------------------+-----------+---------------------+
| user_id | total_activity | z_score | normalized_score | segment   | updated_at          |
+---------+----------------+---------+------------------+-----------+---------------------+
|    1989 |             26 |    3.11 |           100.00 | Superstar | 2026-05-XX XX:XX:XX |
|   31301 |             23 |    2.65 |            88.46 | Superstar | 2026-05-XX XX:XX:XX |
|   28548 |             21 |    2.33 |            80.77 | Superstar | 2026-05-XX XX:XX:XX |
|    1427 |             19 |    2.02 |            73.08 | Superstar | 2026-05-XX XX:XX:XX |
|    1522 |             19 |    2.02 |            73.08 | Superstar | 2026-05-XX XX:XX:XX |
+---------+----------------+---------+------------------+-----------+---------------------+
```

Distribusi segmen:

```sql
SELECT segment, COUNT(*) FROM user_engagement_scores GROUP BY segment;
```

> **Insight**: 
> - Top user (1989) jadi Superstar dengan skor sempurna 100
> - Kebanyakan user di-segment 'Passive' karena distribusi `raw_activity` cukup right-skewed — banyak user dengan aktivitas minim, sedikit yang power-user
> 
> Normalisasi ke 0-100 membuat angka ini mudah dipahami tim bisnis. Mereka tidak perlu tahu apa itu z-score — cukup lihat "skor 0-100".

Ketik `exit` untuk keluar dari MySQL prompt.

---

### 1.7 Membuat TRIGGER — Automasi

**Apa itu Trigger?**
Kode yang otomatis jalan saat ada INSERT, UPDATE, atau DELETE di tabel tertentu.

**Kasus**: Setiap ada user baru yang mulai berlangganan (INSERT ke `subscriptions`), otomatis buatkan entry di `user_engagement_scores` dengan skor 0. Kita pakai `subscriptions` sebagai pemicu karena tabel `users` di project ini adalah VIEW — view tidak bisa di-INSERT dan tidak bisa punya trigger.

Masuk lagi ke MySQL:

```bash
docker exec -it mikroskil-mysql-topik2 mysql -uroot -ppassword db_rey_mikroskil
```

Buat Trigger:

```sql
DELIMITER //

CREATE TRIGGER trg_after_subscription_insert
AFTER INSERT ON subscriptions
FOR EACH ROW
BEGIN
    INSERT IGNORE INTO user_engagement_scores (user_id, total_activity, z_score, normalized_score, segment)
    VALUES (NEW.user_id, 0, 0, 0, 'New Joiner');
END //

DELIMITER ;
```

Penjelasan:
- `AFTER INSERT ON subscriptions`: Trigger ini jalan SETELAH ada INSERT di tabel `subscriptions`
- `NEW.user_id`: Referensi ke user_id dari baris subscription yang baru di-insert
- `INSERT IGNORE`: Skip jika user_id sudah punya entry (user lama yang re-subscribe tidak di-reset)
- Otomatis buat entry di `user_engagement_scores` dengan skor 0 dan segment 'New Joiner'

**Test Trigger — Insert Subscription Baru:**

```sql
INSERT INTO subscriptions (user_id, start_date, status) VALUES (999, '2025-05-01', 'active');
```

Cek apakah trigger jalan — user 999 harusnya otomatis muncul di `user_engagement_scores`:

```sql
SELECT * FROM user_engagement_scores WHERE user_id = 999;
```

Output:
```
+---------+----------------+---------+------------------+------------+---------------------+
| user_id | total_activity | z_score | normalized_score | segment    | updated_at          |
+---------+----------------+---------+------------------+------------+---------------------+
|     999 |              0 |       0 |                0 | New Joiner | 2025-05-XX XX:XX:XX |
+---------+----------------+---------+------------------+------------+---------------------+
```

Trigger berhasil! Subscriber baru otomatis punya entry di tabel skor.

Tapi skornya masih 0 karena belum ada aktivitas. Refresh ranking untuk update:

```sql
CALL sp_refresh_engagement_rankings();
SELECT * FROM user_engagement_scores WHERE user_id = 999;
```

> **Gotcha (PENTING)**: Trigger itu "invisible" — developer lain mungkin tidak tahu ada logic yang otomatis jalan. Di perusahaan besar, trigger sering dihindari karena sulit di-debug. Lebih baik logic ditaruh di aplikasi (service layer).

Ketik `exit` untuk keluar dari MySQL.

---

### 1.8 Export Hasil Query ke CSV

Setelah analisis di MySQL, sering kita perlu share hasilnya ke tim non-teknis (Google Sheet, Excel). Pakai agregasi cohort sebagai contoh.

> ⚠️ **PENTING — Baca dulu sebelum copy-paste**
>
> Perintah di bawah ini adalah **shell command** (dijalankan di terminal host), **BUKAN SQL**.
> Kalau prompt kamu masih `mysql>`, perintah ini **tidak akan jalan** (akan terlihat seperti hang).
>
> **Langkah 1**: Pastikan kamu sudah keluar dari MySQL prompt. Di `mysql>` ketik:
> ```
> exit;
> ```
> Prompt akan kembali ke shell biasa (misal `$` atau `%`). Baru jalankan perintah di bawah.

Copy-paste perintah berikut **dalam satu baris** (jangan dipecah jadi multi-line):

```bash
docker exec mikroskil-mysql-topik2 mysql -uroot -ppassword db_rey_mikroskil --batch -e "SELECT cohort_month, sub_age_months, COUNT(user_id) AS total_users FROM view_user_cohort GROUP BY cohort_month, sub_age_months ORDER BY cohort_month, sub_age_months;" 2>/dev/null | tr '\t' ',' > cohort_export.csv
```

File `cohort_export.csv` muncul di folder `Topik 2/`. Cek isinya:

```bash
head cohort_export.csv
```

Output:
```
cohort_month,total_users
2024-01-01,78
2024-02-01,80
2024-03-01,10
2024-04-01,548
...
```

Cara kerja:
- `docker exec mikroskil-mysql-topik2 mysql ...`: jalankan mysql client **dari host masuk ke container** — itu kenapa harus dari shell host, bukan dari dalam mysql
- `--batch`: bikin output tab-separated (bukan ASCII table dengan border `|`)
- `2>/dev/null`: buang warning "Using a password on the command line interface" agar tidak mengotori output
- `tr '\t' ','`: ganti tab jadi koma (pakai `tr` bukan `sed` — `sed` di macOS tidak handle `\t` dengan benar)
- `>`: redirect ke file di host

> **Gotcha — kalau perintah seperti hang**: paling sering karena masih di dalam `mysql>` prompt. Cek prompt kamu. Kalau ada teks `mysql>` di awal baris, ketik `exit;` dulu. Penyebab lain: query di-pecah jadi multi-line dengan newline di tengah `-e "..."` — pakai versi satu-baris di atas. Atau: view `view_user_cohort` belum dibuat — selesaikan dulu Section 1.4.

> **Kapan pilih yang mana?**
> - **Cara A**: quick ad-hoc export, satu query, value-nya "rapi"
> - **Cara B**: production pipeline, query besar, butuh hasil di server-side
> - **Cara C**: butuh transformasi tambahan (rename kolom, format tanggal, gabung beberapa query) — Python paling enak

---

## BAGIAN 2: DEMO 2 — Gemini API + MySQL Analysis
### (AI-Augmented Data Analysis)

### 2.1 Setup Python Environment

Kembali ke terminal (di folder `Topik 2`):

```bash
make setup
```

Apa yang terjadi:
- Cek apakah `uv` sudah terinstall, jika belum → install
- Buat virtual environment (`.venv`)
- Install semua dependencies: `mysql-connector-python`, `google-genai`, `jupyterlab`, `ipykernel`

Setelah selesai, verifikasi:

```bash
make test
```

Output yang diharapkan:
```
mysql-connector: OK
google-genai: OK
MySQL container: OK
```

---

### 2.2 Set Gemini API Key via `.env` File

Kita pakai file `.env` agar API key tersimpan aman dan tidak perlu di-export ulang setiap buka terminal baru.

**Langkah 1: Copy template `.env.example` jadi `.env`**

```bash
cp .env.example .env
```

**Langkah 2: Edit file `.env`**

```bash
nano .env
```

Ganti `your-api-key-here` dengan API key kamu:

```
GEMINI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Simpan dan exit (`Ctrl+O`, `Enter`, `Ctrl+X` di nano).

**Langkah 3: Verifikasi**

```bash
cat .env
```

Pastikan API key-nya sudah benar.

> **Kenapa `.env`?**
> - API key tersimpan di file, tidak perlu `export` ulang setiap buka terminal
> - File `.env` sudah ada di `.gitignore` — tidak akan ter-commit ke Git
> - Aman untuk development lokal
> - Notebook akan otomatis load API key dari file ini via `python-dotenv`

---

### 2.3 Buka Jupyter Notebook

```bash
make notebook
```

Browser akan terbuka otomatis ke Jupyter Lab. Buka file `gemini_mysql_demo.ipynb`.

---

### 2.4 Jalankan Notebook — Cell by Cell

#### Cell 1: Setup — Imports & Configuration

Klik cell pertama, lalu tekan `Shift + Enter` (atau klik tombol Play).

Apa yang terjadi:
- Import library: `mysql.connector`, `os`, `json`, `re`, `google.genai`
- Setup konfigurasi MySQL (host: localhost, port: 3306, user: root, pass: password)
- Load API key otomatis dari file `.env` (via `python-dotenv`)
- Setup Gemini client dengan API key
- Jika `.env` tidak ada atau GEMINI_API_KEY kosong, akan muncul error

Output yang diharapkan:
```
Setup complete! Imports OK, Gemini client initialized.
```

#### Cell 2: Function Definitions

Klik cell kedua, lalu `Shift + Enter`.

Apa yang terjadi: Mendefinisikan 5 fungsi helper yang akan dipakai di step-step berikutnya:

1. `get_connection()` — buka koneksi ke MySQL
2. `get_schema_info()` — ambil struktur tabel (nama tabel, kolom, tipe data)
3. `ask_gemini_sql(question, schema_text)` — minta Gemini buatkan SQL dari pertanyaan bisnis
4. `execute_query(sql)` — jalankan SQL query ke MySQL, kembalikan hasil
5. `ask_gemini_insights(question, sql, columns, results)` — minta Gemini analisis hasil query

Output yang diharapkan:
```
All functions defined! Ready to run steps.
```

#### Cell 3: Step 1 — Test Koneksi MySQL

`Shift + Enter`

Output yang diharapkan:
```
============================================================
STEP 1: Testing MySQL Connection
============================================================
  Connected! Found 6 tables:
    - health_diaries
    - reyfit_logs
    - subscriptions
    - user_engagement_scores
    - user_logins
    - users

  Koneksi berhasil! Lanjut ke Step 2.
```

> Jika gagal: Pastikan Docker MySQL running (`docker ps`). Jika tidak ada, jalankan `make up`.

#### Cell 4: Step 2 — Ambil Schema Database

`Shift + Enter`

Output yang diharapkan:
```
============================================================
STEP 2: Schema Database
============================================================
Table: health_diaries
    diary_id  int
    user_id  int
    active_month  date
    count_diaries  int

Table: reyfit_logs
    log_id  int
    user_id  int
    active_month  date
    step_counts  int
    total_hydration_ml  int

Table: subscriptions
    subscription_id  int
    user_id  int
    start_date  date
    end_date  date
    status  varchar(20)

Table: user_engagement_scores
    user_id  int
    total_activity  int
    z_score  float
    normalized_score  float
    segment  varchar(50)
    updated_at  timestamp

Table: user_logins
    login_id  int
    user_id  int
    platform  varchar(50)
    last_login_at  datetime

Table: users
    user_id  int
    first_activity  date
    last_activity  date

Total: 6 tables loaded as context for Gemini.
```

> **Kenapa ini penting?** Schema ini jadi "konteks" yang dikasih ke Gemini. Tanpa schema, Gemini tidak tahu tabel apa saja yang tersedia dan kolom apa yang bisa di-query.

#### Cell 5: Step 3 — Gemini Generate SQL

`Shift + Enter`

Pertanyaan yang dikirim ke Gemini:
> "Berapa jumlah user di setiap cohort bulan berdasarkan start_date mereka? Kelompokkan berdasarkan tahun-bulan dan urutkan dari yang paling awal."

Output yang diharapkan (SQL dari Gemini mungkin sedikit berbeda tapi logic-nya sama):
```
============================================================
STEP 3: Gemini Generate SQL
============================================================

  Pertanyaan: Berapa jumlah user di setiap cohort bulan berdasarkan start_date mereka? Kelompokkan berdasarkan tahun-bulan dan urutkan dari yang paling awal.

  Gemini-generated SQL:
  SELECT DATE_FORMAT(start_date, '%Y-%m') AS cohort_month, COUNT(user_id) AS total_users FROM subscriptions GROUP BY DATE_FORMAT(start_date, '%Y-%m') ORDER BY cohort_month ASC
```

> **Perhatikan**: Gemini menerjemahkan pertanyaan bahasa Indonesia ke SQL query. Ini menunjukkan kemampuan LLM untuk "translate" kebutuhan bisnis ke kode.

#### Cell 6: Step 4 — Execute Query

`Shift + Enter`

Output yang diharapkan (contoh — angka tergantung data XLSX):
```
============================================================
STEP 4: Executing Gemini's SQL Query
============================================================

  Query berhasil! 18 rows returned:
    {'cohort_month': '2024-01', 'total_users': 78}
    {'cohort_month': '2024-02', 'total_users': 80}
    {'cohort_month': '2024-03', 'total_users': 10}
    {'cohort_month': '2024-04', 'total_users': 548}
    {'cohort_month': '2024-05', 'total_users': 237}
    {'cohort_month': '2024-06', 'total_users': 124}
    {'cohort_month': '2024-07', 'total_users': 895}
    ... (11 more rows)

  Lanjut ke Step 5 untuk analisis dari Gemini.
```

#### Cell 7: Step 5 — Gemini Analisis Hasil

`Shift + Enter`

Output yang diharapkan (insight dari Gemini bisa berbeda wording-nya):
```
============================================================
STEP 5: Gemini Analyzes Results
============================================================

  Gemini Insight:
  [Gemini akan memberikan analisis dalam bahasa Indonesia, contohnya:]
  
  Berdasarkan hasil query, dapat dilihat bahwa:
  
  1. **Ringkasan**: Akuisisi sangat tidak merata antar bulan. Juli 2024 jadi puncak dengan 895 user baru, sementara Maret 2024 hanya 10 user — gap hampir 90x.
  
  2. **Kesimpulan bisnis**: Spike di April (548) dan Juli (895) sangat menonjol — kemungkinan besar hasil campaign atau promo. Tim growth perlu cek kalender campaign untuk attribute ke event apa, lalu replikasi pola yang berhasil.
  
  3. **Pola menarik**: Distribusi heavily skewed — beberapa bulan dominan, banyak bulan kecil. Bukan tipe pertumbuhan organik linear, tapi event-driven.
```

> **Ini adalah inti dari Demo 2**: Dari pertanyaan bisnis -> Gemini generate SQL -> Execute -> Gemini kasih insight dalam bahasa yang mudah dipahami. Seluruh pipeline otomatis.

#### Cell 8: Step 6 — Full Pipeline (3 Skenario)

`Shift + Enter`

Ini adalah demo lengkap — 3 skenario dijalankan otomatis:

**Skenario 1: Cohort Retention**
- Pertanyaan: "Berapa jumlah user di setiap cohort bulan?"
- Gemini generate SQL -> Execute -> Gemini Insight

**Skenario 2: User Engagement Breakdown**
- Pertanyaan: "Untuk setiap user, hitung total: (a) login dari user_logins, (b) bulan aktif di reyfit_logs, (c) bulan ada catatan di health_diaries"
- Gemini generate SQL (JOIN 3 tabel) -> Execute -> Gemini Insight

**Skenario 3: Subscription Duration Analysis**
- Pertanyaan: "Hitung berapa hari setiap user sudah berlangganan"
- Gemini generate SQL (DATEDIFF) -> Execute -> Gemini Insight

Setiap skenario akan menampilkan:
1. Pertanyaan bisnis
2. SQL yang di-generate Gemini
3. Hasil query (rows)
4. Insight dari Gemini dalam bahasa Indonesia

---

### 2.5 Eksperimen Mandiri

Setelah berhasil menjalankan semua cell, coba eksperimen ini:

**Eksperimen 1: Ubah Pertanyaan Bisnis**
Di Cell 3 (Step 3), ganti `question_1` dengan pertanyaan kamu sendiri:

```python
question_1 = "Berapa rata-rata total_hydration_ml per user dari tabel reyfit_logs (ignore NULL)?"
```

Lihat SQL apa yang Gemini generate. Apakah valid? Apakah hasilnya sesuai ekspektasi?

**Eksperimen 2: Tambah Skenario Baru**
Di Cell 8 (Step 6), tambahkan skenario ke-4 di list `scenarios`:

```python
{
    "title": "Skenario 4: User Paling Aktif di Reyfit",
    "question": "Siapa 10 user dengan jumlah record reyfit_logs terbanyak? Tampilkan user_id dan jumlah bulan aktifnya.",
},
```

**Eksperimen 3: Coba Model Gemini Lain**
Di Cell 1 (Setup), ganti model:

```python
GEMINI_MODEL = "gemini-1.5-flash"  # atau "gemini-2.0-flash-lite"
```

Bandingkan kualitas SQL dan insight yang dihasilkan.

**Eksperimen 4: Pindahkan `.env` ke lokasi lain**

File `.env` harus ada di folder yang sama dengan notebook. Jika kamu pindah notebook ke folder lain, copy juga `.env`-nya:

```bash
cp .env /path/to/new/location/
```

**Eksperimen 5: Tambah Visualisasi**
Install matplotlib dan plot hasil query:

```python
import matplotlib.pyplot as plt

# Setelah execute query, plot hasilnya
months = [row['cohort_month'] for row in results_1]
counts = [row['total_users'] for row in results_1]
plt.bar(months, counts)
plt.xlabel('Cohort Month')
plt.ylabel('Total Users')
plt.title('User Cohort Distribution')
plt.show()
```

---

## BAGIAN 3: ALTERNATIF — Google Colab (No Local Setup)

Jika kamu tidak ingin setup lokal, bisa jalankan notebook di Google Colab:

1. Buka https://colab.research.google.com
2. Upload `gemini_mysql_demo.ipynb`
3. Di cell pertama, tambahkan:
   ```python
   !pip install mysql-connector-python google-genai python-dotenv
   import os
   os.environ["GEMINI_API_KEY"] = "your-api-key-here"
   ```
4. Jalankan cell satu per satu

> **Catatan**: Colab berjalan di cloud, jadi tidak bisa connect ke MySQL lokal. Gunakan MySQL cloud (Railway, Render, atau Google Cloud SQL) dan ubah `MYSQL_CONFIG` di notebook.

---

## BAGIAN 4: CLEANUP

Setelah selesai belajar, bersihkan environment:

```bash
# Stop MySQL container
make down

# Atau bersih total (hapus .venv + container)
make clean
```

---

## LAMPIRAN A: Make Commands Reference

```
make help       # Lihat semua perintah yang tersedia
make setup      # Install uv, buat venv, install deps
make up         # Start MySQL container
make down       # Stop MySQL container
make db-sync    # Reset database (fresh data dari init_mysql.sql)
make notebook   # Launch Jupyter notebook
make test       # Test koneksi MySQL + import Python
make clean      # Hapus .venv, stop containers, bersihkan cache
```

> **Alternatif untuk Windows (tanpa `make`):**
>
> `make` tidak terinstall secara default di Windows. Kamu bisa menggunakan command berikut secara langsung:
>
> ```powershell
> # Install uv & setup dependencies
> winget install --id=astral-sh.uv
> uv venv
> uv sync
>
> # Start MySQL container
> docker compose up -d
> # (tunggu ~5 detik sampai MySQL ready)
>
> # Launch Jupyter notebook
> uv run jupyter lab gemini_mysql_demo.ipynb
>
> # Stop MySQL
> docker compose down
>
> # Reset database (hapus volume + recreate)
> docker compose down -v
> docker compose up -d
>
> # Test import Python + cek container
> uv run python -c "import mysql.connector; print('OK')"
> docker compose ps
>
> # Bersihkan
> docker compose down -v
> rmdir /s /q .venv
> ```
>
> Atau, install `make` via: WSL, Chocolatey (`choco install make`), atau Scoop (`scoop install make`).

---

## LAMPIRAN B: Struktur File

```
Topik 2/
├── Makefile                    # Makefile: satu command untuk semua
├── docker-compose.yml          # MySQL-only Docker (lightweight)
├── pyproject.toml              # Python dependencies (uv)
├── .env.example                # Template untuk API key (copy jadi .env)
├── .gitignore                  # Exclude .venv, .env, __pycache__, data/
├── gemini_mysql_demo.ipynb     # Jupyter Notebook (cell-by-cell)
├── WALKTHROUGH_LENGKAP.md      # Panduan lengkap (dokumen ini)
├── init_mysql.sql              # Schema saja (tanpa data)
├── load_data.py                # Baca XLSX dari data/, INSERT ke MySQL
├── data/                       # XLSX dari REY (gitignored, disediakan dosen)
│   ├── [MIKROSKIL] Project 1 - Subscriptions Cohort Data.xlsx
│   └── [MIKROSKIL] Project 2 - User Activity Data.xlsx
└── materi/
    ├── Slide_Paparan.md        # Slide presentasi
    └── Live_Code_MySQL.md      # Live code script (Demo 1)
```

---

## TROUBLESHOOTING

| Masalah | Solusi |
|---------|--------|
| `uv: command not found` | Install: `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `Port 3306 already in use` | Ada MySQL lain running. Stop: `docker stop $(docker ps -q -f publish=3306)` |
| `ModuleNotFoundError` | Pastikan `uv sync` sudah jalan dan pakai `uv run` untuk launch |
| `Access denied for user 'root'` | Cek password di `docker-compose.yml` (default: `password`) |
| `Unknown database 'db_rey_mikroskil'` | Reset: `docker compose down && docker compose up -d` |
| Gemini API error 403 | Cek API key valid di `.env` dan di https://aistudio.google.com |
| Gemini API error 429 | Rate limit — tunggu beberapa detik, coba lagi |
| Query error dari Gemini | Gemini mungkin salah nama kolom — cek schema, coba pertanyaan lebih spesifik |
| Docker tidak bisa connect | Pastikan Docker Desktop running (`docker info`) |
| Jupyter tidak buka browser | Buka manual: copy URL yang muncul di terminal ke browser |

---

## RANGKUMAN: Apa yang Sudah Dipelajari?

### Demo 1: MySQL Advanced
1. **VIEW** — tabel virtual untuk menyederhanakan query (Cohort Analysis)
2. **Window Functions** — AVG() OVER(), STDDEV() OVER() untuk statistik (Z-Score)
3. **Stored Procedure** — logic terpusat yang bisa dipanggil satu kali (Refresh Ranking)
4. **Trigger** — automasi saat INSERT/UPDATE/DELETE (Auto-seed new subscription)

### Demo 2: AI-Augmented Analysis
1. **Schema as Context** — kasih tahu AI struktur database kita
2. **Text-to-SQL** — AI menerjemahkan pertanyaan bisnis ke query
3. **Execute & Validate** — jalankan query AI, cek hasilnya
4. **AI Insights** — AI menjelaskan hasil query dalam bahasa manusia

### Pelajaran Penting
- AI **bukan pengganti** skill SQL — tapi **amplifier** untuk analisis
- Human review tetap wajib: AI bisa hallucinate kolom yang tidak ada
- Analytics Engineer modern: fokus di **pertanyaan bisnis yang tepat**, AI bantu eksekusi

---

&copy; 2026 REY x Universitas Mikroskil
